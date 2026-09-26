#include "pauli_gles_image.h"

#include <GLES2/gl2.h>

#include <stddef.h>

static int current_width = 1;
static int current_height = 1;

static GLuint program = 0;
static GLuint texture = 0;
static GLuint vertex_buffer = 0;

static GLint position_location = -1;
static GLint tex_coord_location = -1;
static GLint screen_scale_location = -1;
static GLint texture_location = -1;

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
    "    gl_Position = vec4("
    "a_position * u_screen_scale, 0.0, 1.0);\n"
    "}\n";

static const char *fragment_shader_source =
    "precision mediump float;\n"
    "uniform sampler2D u_texture;\n"
    "varying vec2 v_tex_coord;\n"
    "void main(void) {\n"
    "    gl_FragColor = texture2D("
    "u_texture, v_tex_coord);\n"
    "}\n";

static GLuint compile_shader(
    GLenum type,
    const char *source
) {
    GLuint shader = glCreateShader(type);
    if (shader == 0) {
        return 0;
    }

    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);

    GLint compiled = GL_FALSE;
    glGetShaderiv(
        shader,
        GL_COMPILE_STATUS,
        &compiled
    );

    if (compiled != GL_TRUE) {
        glDeleteShader(shader);
        return 0;
    }

    return shader;
}

static int create_program(void) {
    const GLuint vertex_shader =
        compile_shader(
            GL_VERTEX_SHADER,
            vertex_shader_source
        );

    if (vertex_shader == 0) {
        return 0;
    }

    const GLuint fragment_shader =
        compile_shader(
            GL_FRAGMENT_SHADER,
            fragment_shader_source
        );

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
    glGetProgramiv(
        program,
        GL_LINK_STATUS,
        &linked
    );

    if (linked != GL_TRUE) {
        glDeleteProgram(program);
        program = 0;
        return 0;
    }

    position_location =
        glGetAttribLocation(
            program,
            "a_position"
        );

    tex_coord_location =
        glGetAttribLocation(
            program,
            "a_tex_coord"
        );

    screen_scale_location =
        glGetUniformLocation(
            program,
            "u_screen_scale"
        );

    texture_location =
        glGetUniformLocation(
            program,
            "u_texture"
        );

    return
        position_location >= 0 &&
        tex_coord_location >= 0 &&
        screen_scale_location >= 0 &&
        texture_location >= 0;
}

int pauli_gles_image_start(
    int width,
    int height,
    int image_side,
    const uint8_t *pixels
) {
    current_width = width > 0 ? width : 1;
    current_height = height > 0 ? height : 1;

    if (!create_program()) {
        pauli_gles_image_stop();
        return 0;
    }

    glGenTextures(1, &texture);
    if (texture == 0) {
        pauli_gles_image_stop();
        return 0;
    }

    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(
        GL_TEXTURE_2D,
        GL_TEXTURE_MIN_FILTER,
        GL_LINEAR
    );
    glTexParameteri(
        GL_TEXTURE_2D,
        GL_TEXTURE_MAG_FILTER,
        GL_LINEAR
    );
    glTexParameteri(
        GL_TEXTURE_2D,
        GL_TEXTURE_WRAP_S,
        GL_CLAMP_TO_EDGE
    );
    glTexParameteri(
        GL_TEXTURE_2D,
        GL_TEXTURE_WRAP_T,
        GL_CLAMP_TO_EDGE
    );

    glGenBuffers(1, &vertex_buffer);
    if (vertex_buffer == 0) {
        pauli_gles_image_stop();
        return 0;
    }

    glBindBuffer(
        GL_ARRAY_BUFFER,
        vertex_buffer
    );
    glBufferData(
        GL_ARRAY_BUFFER,
        sizeof(quad_vertices),
        quad_vertices,
        GL_STATIC_DRAW
    );

    pauli_gles_image_upload(
        image_side,
        pixels
    );

    return 1;
}

void pauli_gles_image_resize(
    int width,
    int height
) {
    current_width = width > 0 ? width : 1;
    current_height = height > 0 ? height : 1;
}

void pauli_gles_image_upload(
    int image_side,
    const uint8_t *pixels
) {
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

    glTexImage2D(
        GL_TEXTURE_2D,
        0,
        GL_RGB,
        image_side,
        image_side,
        0,
        GL_RGB,
        GL_UNSIGNED_BYTE,
        pixels
    );
}

void pauli_gles_image_draw(void) {
    if (
        program == 0 ||
        texture == 0 ||
        vertex_buffer == 0
    ) {
        return;
    }

    glViewport(
        0,
        0,
        current_width,
        current_height
    );

    glClearColor(
        0.075f,
        0.090f,
        0.115f,
        1.0f
    );
    glClear(GL_COLOR_BUFFER_BIT);

    float scale_x = 1.0f;
    float scale_y = 1.0f;

    if (current_width < current_height) {
        scale_y =
            (float)current_width /
            (float)current_height;
    } else if (current_height < current_width) {
        scale_x =
            (float)current_height /
            (float)current_width;
    }

    glUseProgram(program);
    glUniform2f(
        screen_scale_location,
        scale_x,
        scale_y
    );
    glUniform1i(texture_location, 0);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);

    glBindBuffer(
        GL_ARRAY_BUFFER,
        vertex_buffer
    );

    glEnableVertexAttribArray(
        (GLuint)position_location
    );
    glEnableVertexAttribArray(
        (GLuint)tex_coord_location
    );

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

    glDrawArrays(
        GL_TRIANGLES,
        0,
        6
    );

    glDisableVertexAttribArray(
        (GLuint)position_location
    );
    glDisableVertexAttribArray(
        (GLuint)tex_coord_location
    );
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

void pauli_gles_image_stop(void) {
    if (vertex_buffer != 0) {
        glDeleteBuffers(
            1,
            &vertex_buffer
        );
        vertex_buffer = 0;
    }

    if (texture != 0) {
        glDeleteTextures(
            1,
            &texture
        );
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
