module pauli_renderer;

import pauli_orbitals :
    OrbitalState,
    background_blue,
    background_green,
    background_red,
    render_side;

private alias GLenum = uint;
private alias GLboolean = ubyte;
private alias GLbitfield = uint;
private alias GLint = int;
private alias GLsizei = int;
private alias GLuint = uint;
private alias GLfloat = float;
private alias GLsizeiptr = ptrdiff_t;

private enum GLenum GL_TRIANGLES = 0x0004;
private enum GLenum GL_FLOAT = 0x1406;
private enum GLenum GL_RGB = 0x1907;
private enum GLenum GL_UNSIGNED_BYTE = 0x1401;
private enum GLenum GL_ARRAY_BUFFER = 0x8892;
private enum GLenum GL_STATIC_DRAW = 0x88E4;
private enum GLenum GL_TEXTURE_2D = 0x0DE1;
private enum GLenum GL_TEXTURE0 = 0x84C0;
private enum GLenum GL_TEXTURE_MIN_FILTER = 0x2801;
private enum GLenum GL_TEXTURE_MAG_FILTER = 0x2800;
private enum GLenum GL_TEXTURE_WRAP_S = 0x2802;
private enum GLenum GL_TEXTURE_WRAP_T = 0x2803;
private enum GLint GL_LINEAR = 0x2601;
private enum GLint GL_CLAMP_TO_EDGE = 0x812F;
private enum GLenum GL_UNPACK_ALIGNMENT = 0x0CF5;
private enum GLbitfield GL_COLOR_BUFFER_BIT = 0x00004000;
private enum GLenum GL_VERTEX_SHADER = 0x8B31;
private enum GLenum GL_FRAGMENT_SHADER = 0x8B30;
private enum GLenum GL_COMPILE_STATUS = 0x8B81;
private enum GLenum GL_LINK_STATUS = 0x8B82;
private enum GLint GL_FALSE = 0;
private enum GLint GL_TRUE = 1;

private extern(C) {
    GLuint glCreateShader(GLenum type);
    void glShaderSource(
        GLuint shader,
        GLsizei count,
        const(char)** strings,
        const(GLint)* lengths
    );
    void glCompileShader(GLuint shader);
    void glGetShaderiv(GLuint shader, GLenum pname, GLint* params);
    void glDeleteShader(GLuint shader);

    GLuint glCreateProgram();
    void glAttachShader(GLuint program, GLuint shader);
    void glLinkProgram(GLuint program);
    void glGetProgramiv(GLuint program, GLenum pname, GLint* params);
    void glDeleteProgram(GLuint program);
    GLint glGetAttribLocation(GLuint program, const(char)* name);
    GLint glGetUniformLocation(GLuint program, const(char)* name);

    void glActiveTexture(GLenum texture_unit);
    void glBindTexture(GLenum target, GLuint texture);
    void glPixelStorei(GLenum pname, GLint parameter);
    void glTexImage2D(
        GLenum target,
        GLint level,
        GLint internal_format,
        GLsizei width,
        GLsizei height,
        GLint border,
        GLenum format,
        GLenum type,
        const(void)* pixels
    );
    void glGenTextures(GLsizei count, GLuint* textures);
    void glTexParameteri(GLenum target, GLenum pname, GLint parameter);
    void glDeleteTextures(GLsizei count, const(GLuint)* textures);

    void glGenBuffers(GLsizei count, GLuint* buffers);
    void glBindBuffer(GLenum target, GLuint buffer);
    void glBufferData(
        GLenum target,
        GLsizeiptr size,
        const(void)* data,
        GLenum usage
    );
    void glDeleteBuffers(GLsizei count, const(GLuint)* buffers);

    void glViewport(GLint x, GLint y, GLsizei width, GLsizei height);
    void glClearColor(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);
    void glClear(GLbitfield mask);
    void glUseProgram(GLuint program);
    void glUniform2f(GLint location, GLfloat first, GLfloat second);
    void glUniform1i(GLint location, GLint value);
    void glEnableVertexAttribArray(GLuint index);
    void glDisableVertexAttribArray(GLuint index);
    void glVertexAttribPointer(
        GLuint index,
        GLint size,
        GLenum type,
        GLboolean normalized,
        GLsizei stride,
        const(void)* pointer
    );
    void glDrawArrays(GLenum mode, GLint first, GLsizei count);
}

private int current_width = 1;
private int current_height = 1;
private OrbitalState orbital_state;

private GLuint program = 0;
private GLuint texture = 0;
private GLuint vertex_buffer = 0;

private GLint position_location = -1;
private GLint tex_coord_location = -1;
private GLint screen_scale_location = -1;
private GLint texture_location = -1;

private bool pixels_dirty = true;
private ubyte[render_side * render_side * 3] pixels;

private immutable GLfloat[24] quad_vertices = [
    -1.0f, -1.0f, 0.0f, 0.0f,
     1.0f, -1.0f, 1.0f, 0.0f,
     1.0f,  1.0f, 1.0f, 1.0f,
    -1.0f, -1.0f, 0.0f, 0.0f,
     1.0f,  1.0f, 1.0f, 1.0f,
    -1.0f,  1.0f, 0.0f, 1.0f
];

private immutable(char)[] vertex_shader_source =
    "attribute vec2 a_position;\n"
    ~ "attribute vec2 a_tex_coord;\n"
    ~ "uniform vec2 u_screen_scale;\n"
    ~ "varying vec2 v_tex_coord;\n"
    ~ "void main(void) {\n"
    ~ "    v_tex_coord = a_tex_coord;\n"
    ~ "    gl_Position = vec4(a_position * u_screen_scale, 0.0, 1.0);\n"
    ~ "}\n";

private immutable(char)[] fragment_shader_source =
    "precision mediump float;\n"
    ~ "uniform sampler2D u_texture;\n"
    ~ "varying vec2 v_tex_coord;\n"
    ~ "void main(void) {\n"
    ~ "    gl_FragColor = texture2D(u_texture, v_tex_coord);\n"
    ~ "}\n";

private GLuint compile_shader(GLenum type, const(char)[] source) {
    const shader = glCreateShader(type);
    if (shader == 0) {
        return 0;
    }

    const(char)* source_pointer = source.ptr;
    glShaderSource(shader, 1, &source_pointer, null);
    glCompileShader(shader);

    GLint compiled = GL_FALSE;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if (compiled != GL_TRUE) {
        glDeleteShader(shader);
        return 0;
    }

    return shader;
}

private bool create_program() {
    const vertex_shader = compile_shader(GL_VERTEX_SHADER, vertex_shader_source);
    if (vertex_shader == 0) {
        return false;
    }

    const fragment_shader = compile_shader(
        GL_FRAGMENT_SHADER,
        fragment_shader_source
    );
    if (fragment_shader == 0) {
        glDeleteShader(vertex_shader);
        return false;
    }

    program = glCreateProgram();
    if (program == 0) {
        glDeleteShader(vertex_shader);
        glDeleteShader(fragment_shader);
        return false;
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
        return false;
    }

    position_location = glGetAttribLocation(program, "a_position".ptr);
    tex_coord_location = glGetAttribLocation(program, "a_tex_coord".ptr);
    screen_scale_location = glGetUniformLocation(program, "u_screen_scale".ptr);
    texture_location = glGetUniformLocation(program, "u_texture".ptr);

    return
        position_location >= 0 &&
        tex_coord_location >= 0 &&
        screen_scale_location >= 0 &&
        texture_location >= 0;
}

private void upload_pixels() {
    if (pixels_dirty) {
        orbital_state.render_pixels(pixels[]);
        pixels_dirty = false;
    }

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexImage2D(
        GL_TEXTURE_2D,
        0,
        cast(GLint) GL_RGB,
        render_side,
        render_side,
        0,
        GL_RGB,
        GL_UNSIGNED_BYTE,
        pixels.ptr
    );
}

extern(C) int pauli_renderer_start(int width, int height, int gles_major) {
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
        cast(GLsizeiptr) quad_vertices.sizeof,
        quad_vertices.ptr,
        GL_STATIC_DRAW
    );

    pixels_dirty = true;
    upload_pixels();
    return 1;
}

extern(C) void pauli_renderer_resize(int width, int height) {
    current_width = width > 0 ? width : 1;
    current_height = height > 0 ? height : 1;
}

extern(C) void pauli_renderer_drag(float delta_x, float delta_y) {
    orbital_state.drag(delta_x, delta_y);
    pixels_dirty = true;
}

extern(C) void pauli_renderer_cycle_orbital() {
    orbital_state.cycle_orbital();
    pixels_dirty = true;
}

extern(C) void pauli_renderer_draw() {
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
        scale_y = cast(float) current_width / cast(float) current_height;
    } else if (current_height < current_width) {
        scale_x = cast(float) current_height / cast(float) current_width;
    }

    glUseProgram(program);
    glUniform2f(screen_scale_location, scale_x, scale_y);
    glUniform1i(texture_location, 0);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);

    glBindBuffer(GL_ARRAY_BUFFER, vertex_buffer);
    glEnableVertexAttribArray(cast(GLuint) position_location);
    glEnableVertexAttribArray(cast(GLuint) tex_coord_location);

    glVertexAttribPointer(
        cast(GLuint) position_location,
        2,
        GL_FLOAT,
        cast(GLboolean) GL_FALSE,
        cast(GLsizei) (4 * GLfloat.sizeof),
        null
    );
    glVertexAttribPointer(
        cast(GLuint) tex_coord_location,
        2,
        GL_FLOAT,
        cast(GLboolean) GL_FALSE,
        cast(GLsizei) (4 * GLfloat.sizeof),
        cast(const(void)*) (2 * GLfloat.sizeof)
    );

    glDrawArrays(GL_TRIANGLES, 0, 6);

    glDisableVertexAttribArray(cast(GLuint) position_location);
    glDisableVertexAttribArray(cast(GLuint) tex_coord_location);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

extern(C) void pauli_renderer_stop() {
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
