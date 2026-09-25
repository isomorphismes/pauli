#include <GLES2/gl2.h>

#include <math.h>
#include <stdint.h>
#include <stddef.h>

#include "pauli_renderer.h"

#define RENDER_SIDE 128
#define RAY_STEPS 28

static const float pi_value = 3.14159265358979323846f;
static const float view_half_extent = 1.08f;

static const float background_red = 0.075f;
static const float background_green = 0.090f;
static const float background_blue = 0.115f;

static const float positive_red = 0.18f;
static const float positive_green = 0.68f;
static const float positive_blue = 1.00f;

static const float negative_red = 1.00f;
static const float negative_green = 0.35f;
static const float negative_blue = 0.12f;

static int current_width = 1;
static int current_height = 1;
static int current_family = 1;

static float yaw = 0.0f;
static float pitch = 0.0f;

static GLuint program = 0;
static GLuint texture = 0;
static GLuint vertex_buffer = 0;

static GLint position_location = -1;
static GLint tex_coord_location = -1;
static GLint screen_scale_location = -1;
static GLint texture_location = -1;

static int pixels_dirty = 1;
static uint8_t pixels[RENDER_SIDE * RENDER_SIDE * 3];

static const GLfloat quad_vertices[] = {
    -1.0f, -1.0f, 0.0f, 0.0f,
     1.0f, -1.0f, 1.0f, 0.0f,
     1.0f,  1.0f, 1.0f, 1.0f,
    -1.0f, -1.0f, 0.0f, 0.0f,
     1.0f,  1.0f, 1.0f, 1.0f,
    -1.0f,  1.0f, 0.0f, 1.0f
};

static const char *vertex_shader_source =
    "attribute vec2 a_position;\n"
    "attribute vec2 a_tex_coord;\n"
    "uniform vec2 u_screen_scale;\n"
    "varying vec2 v_tex_coord;\n"
    "void main(void) {\n"
    "    v_tex_coord = a_tex_coord;\n"
    "    gl_Position = vec4(a_position * u_screen_scale, 0.0, 1.0);\n"
    "}\n";

static const char *fragment_shader_source =
    "precision mediump float;\n"
    "uniform sampler2D u_texture;\n"
    "varying vec2 v_tex_coord;\n"
    "void main(void) {\n"
    "    gl_FragColor = texture2D(u_texture, v_tex_coord);\n"
    "}\n";

static float clamp_channel(float value) {
    if (value < 0.0f) {
        return 0.0f;
    }
    if (value > 1.0f) {
        return 1.0f;
    }
    return value;
}

static uint8_t channel_to_byte(float value) {
    return (uint8_t)floorf(255.0f * clamp_channel(value) + 0.5f);
}

static void rotate_into_orbital(
    float x,
    float y,
    float z,
    float *orbital_x,
    float *orbital_y,
    float *orbital_z
) {
    const float cos_yaw = cosf(yaw);
    const float sin_yaw = sinf(yaw);
    const float cos_pitch = cosf(pitch);
    const float sin_pitch = sinf(pitch);

    const float yaw_x = cos_yaw * x + sin_yaw * z;
    const float yaw_z = -sin_yaw * x + cos_yaw * z;

    *orbital_x = yaw_x;
    *orbital_y = cos_pitch * y - sin_pitch * yaw_z;
    *orbital_z = sin_pitch * y + cos_pitch * yaw_z;
}

static void family_parameters(float *physical_radius, float *gain) {
    switch (current_family) {
        case 0:
            *physical_radius = 6.0f;
            *gain = 35.0f;
            break;
        case 1:
            *physical_radius = 8.0f;
            *gain = 90.0f;
            break;
        case 2:
            *physical_radius = 18.0f;
            *gain = 0.06f;
            break;
        default:
            *physical_radius = 30.0f;
            *gain = 0.00045f;
            break;
    }
}

static float orbital_density_and_phase(
    float x,
    float y,
    float z,
    float radius,
    int *negative_phase
) {
    *negative_phase = 0;

    switch (current_family) {
        case 0:
            return expf(-2.0f * radius) / pi_value;

        case 1: {
            *negative_phase = x < 0.0f;
            return x * x * expf(-radius) / (32.0f * pi_value);
        }

        case 2: {
            const float shape = x * y;
            *negative_phase = shape < 0.0f;
            return shape * shape * expf((-2.0f / 3.0f) * radius);
        }

        default: {
            const float shape = x * y * z;
            *negative_phase = shape < 0.0f;
            return shape * shape * expf(-0.5f * radius);
        }
    }
}

static void render_pixel(int pixel_x, int pixel_y, uint8_t *output) {
    const float u =
        -view_half_extent +
        2.0f * view_half_extent *
        ((float)pixel_x + 0.5f) /
        (float)RENDER_SIDE;
    const float v =
        -view_half_extent +
        2.0f * view_half_extent *
        ((float)pixel_y + 0.5f) /
        (float)RENDER_SIDE;

    const float radial_squared = u * u + v * v;
    if (radial_squared >= 1.0f) {
        output[0] = channel_to_byte(background_red);
        output[1] = channel_to_byte(background_green);
        output[2] = channel_to_byte(background_blue);
        return;
    }

    float physical_radius = 1.0f;
    float gain = 1.0f;
    family_parameters(&physical_radius, &gain);

    const float z_limit = sqrtf(1.0f - radial_squared);
    const float normalized_step = 2.0f * z_limit / (float)RAY_STEPS;
    const float physical_step = physical_radius * normalized_step;

    float accumulated_red = 0.0f;
    float accumulated_green = 0.0f;
    float accumulated_blue = 0.0f;

    for (int sample = 0; sample < RAY_STEPS; ++sample) {
        const float z =
            z_limit - ((float)sample + 0.5f) * normalized_step;

        float rotated_x = 0.0f;
        float rotated_y = 0.0f;
        float rotated_z = 0.0f;
        rotate_into_orbital(
            u,
            v,
            z,
            &rotated_x,
            &rotated_y,
            &rotated_z
        );

        const float x = physical_radius * rotated_x;
        const float y = physical_radius * rotated_y;
        const float z_physical = physical_radius * rotated_z;
        const float radius =
            physical_radius * sqrtf(radial_squared + z * z);

        int negative_phase = 0;
        const float density = orbital_density_and_phase(
            x,
            y,
            z_physical,
            radius,
            &negative_phase
        );

        const float red = negative_phase ? negative_red : positive_red;
        const float green =
            negative_phase ? negative_green : positive_green;
        const float blue = negative_phase ? negative_blue : positive_blue;

        accumulated_red += density * red * physical_step;
        accumulated_green += density * green * physical_step;
        accumulated_blue += density * blue * physical_step;
    }

    const float mapped_red = 1.0f - expf(-gain * accumulated_red);
    const float mapped_green = 1.0f - expf(-gain * accumulated_green);
    const float mapped_blue = 1.0f - expf(-gain * accumulated_blue);

    output[0] = channel_to_byte(background_red + mapped_red);
    output[1] = channel_to_byte(background_green + mapped_green);
    output[2] = channel_to_byte(background_blue + mapped_blue);
}

static void render_pixels(void) {
    for (int y = 0; y < RENDER_SIDE; ++y) {
        for (int x = 0; x < RENDER_SIDE; ++x) {
            uint8_t *output =
                &pixels[3 * (y * RENDER_SIDE + x)];
            render_pixel(x, y, output);
        }
    }

    pixels_dirty = 0;
}

static GLuint compile_shader(GLenum type, const char *source) {
    GLuint shader = glCreateShader(type);
    if (shader == 0) {
        return 0;
    }

    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);

    GLint compiled = GL_FALSE;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if (compiled != GL_TRUE) {
        glDeleteShader(shader);
        return 0;
    }

    return shader;
}

static int create_program(void) {
    const GLuint vertex_shader =
        compile_shader(GL_VERTEX_SHADER, vertex_shader_source);
    if (vertex_shader == 0) {
        return 0;
    }

    const GLuint fragment_shader =
        compile_shader(GL_FRAGMENT_SHADER, fragment_shader_source);
    if (fragment_shader == 0) {
        glDeleteShader(vertex_shader);
        return 0;
    }

    program = glCreateProgram();
    if (program == 0) {
        glDeleteShader(vertex_shader);
        glDeleteShader(fragment_shader);
        return 0;
    }

    glAttachShader(program, vertex_shader);
    glAttachShader(program, fragment_shader);
    glLinkProgram(program);

    glDeleteShader(vertex_shader);
    glDeleteShader(fragment_shader);

    GLint linked = GL_FALSE;
    glGetProgramiv(program, GL_LINK_STATUS, &linked);
    if (linked != GL_TRUE) {
        glDeleteProgram(program);
        program = 0;
        return 0;
    }

    position_location = glGetAttribLocation(program, "a_position");
    tex_coord_location = glGetAttribLocation(program, "a_tex_coord");
    screen_scale_location = glGetUniformLocation(program, "u_screen_scale");
    texture_location = glGetUniformLocation(program, "u_texture");

    return
        position_location >= 0 &&
        tex_coord_location >= 0 &&
        screen_scale_location >= 0 &&
        texture_location >= 0;
}

static void upload_pixels(void) {
    if (pixels_dirty) {
        render_pixels();
    }

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexImage2D(
        GL_TEXTURE_2D,
        0,
        GL_RGB,
        RENDER_SIDE,
        RENDER_SIDE,
        0,
        GL_RGB,
        GL_UNSIGNED_BYTE,
        pixels
    );
}

int pauli_renderer_start(int width, int height, int gles_major) {
    if (gles_major < 2) {
        return 0;
    }

    current_width = width > 0 ? width : 1;
    current_height = height > 0 ? height : 1;

    if (!create_program()) {
        pauli_renderer_stop();
        return 0;
    }

    glGenTextures(1, &texture);
    if (texture == 0) {
        pauli_renderer_stop();
        return 0;
    }

    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    glGenBuffers(1, &vertex_buffer);
    if (vertex_buffer == 0) {
        pauli_renderer_stop();
        return 0;
    }

    glBindBuffer(GL_ARRAY_BUFFER, vertex_buffer);
    glBufferData(
        GL_ARRAY_BUFFER,
        sizeof(quad_vertices),
        quad_vertices,
        GL_STATIC_DRAW
    );

    pixels_dirty = 1;
    upload_pixels();
    return 1;
}

void pauli_renderer_resize(int width, int height) {
    current_width = width > 0 ? width : 1;
    current_height = height > 0 ? height : 1;
}

void pauli_renderer_drag(float delta_x, float delta_y) {
    yaw += 4.0f * delta_x;
    pitch += 4.0f * delta_y;

    if (pitch > 1.45f) {
        pitch = 1.45f;
    }
    if (pitch < -1.45f) {
        pitch = -1.45f;
    }

    pixels_dirty = 1;
}

void pauli_renderer_cycle_orbital(void) {
    current_family = (current_family + 1) % 4;
    pixels_dirty = 1;
}

void pauli_renderer_draw(void) {
    if (program == 0 || texture == 0 || vertex_buffer == 0) {
        return;
    }

    if (pixels_dirty) {
        upload_pixels();
    }

    glViewport(0, 0, current_width, current_height);
    glClearColor(
        background_red,
        background_green,
        background_blue,
        1.0f
    );
    glClear(GL_COLOR_BUFFER_BIT);

    float scale_x = 1.0f;
    float scale_y = 1.0f;
    if (current_width < current_height) {
        scale_y = (float)current_width / (float)current_height;
    } else if (current_height < current_width) {
        scale_x = (float)current_height / (float)current_width;
    }

    glUseProgram(program);
    glUniform2f(screen_scale_location, scale_x, scale_y);
    glUniform1i(texture_location, 0);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);

    glBindBuffer(GL_ARRAY_BUFFER, vertex_buffer);
    glEnableVertexAttribArray((GLuint)position_location);
    glEnableVertexAttribArray((GLuint)tex_coord_location);

    glVertexAttribPointer(
        (GLuint)position_location,
        2,
        GL_FLOAT,
        GL_FALSE,
        4 * (GLsizei)sizeof(GLfloat),
        (const void *)0
    );
    glVertexAttribPointer(
        (GLuint)tex_coord_location,
        2,
        GL_FLOAT,
        GL_FALSE,
        4 * (GLsizei)sizeof(GLfloat),
        (const void *)(2 * sizeof(GLfloat))
    );

    glDrawArrays(GL_TRIANGLES, 0, 6);

    glDisableVertexAttribArray((GLuint)position_location);
    glDisableVertexAttribArray((GLuint)tex_coord_location);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

void pauli_renderer_stop(void) {
    if (vertex_buffer != 0) {
        glDeleteBuffers(1, &vertex_buffer);
        vertex_buffer = 0;
    }

    if (texture != 0) {
        glDeleteTextures(1, &texture);
        texture = 0;
    }

    if (program != 0) {
        glDeleteProgram(program);
        program = 0;
    }

    position_location = -1;
    tex_coord_location = -1;
    screen_scale_location = -1;
    texture_location = -1;
}
