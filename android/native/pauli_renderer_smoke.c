/*
 * Packaging/input smoke renderer only.
 *
 * This file deliberately does not draw an orbital. Replace it with the real
 * Pauli renderer implementation while keeping pauli_renderer.h unchanged.
 */

#include <GLES2/gl2.h>

#include <math.h>

#include "pauli_renderer.h"

static int current_width = 1;
static int current_height = 1;
static int current_family = 0;
static float yaw = 0.0f;
static float pitch = 0.0f;

int pauli_renderer_start(int width, int height, int gles_major) {
    if (gles_major < 2) {
        return 0;
    }

    current_width = width > 0 ? width : 1;
    current_height = height > 0 ? height : 1;
    glViewport(0, 0, current_width, current_height);
    return 1;
}

void pauli_renderer_resize(int width, int height) {
    current_width = width > 0 ? width : 1;
    current_height = height > 0 ? height : 1;
    glViewport(0, 0, current_width, current_height);
}

void pauli_renderer_drag(float delta_x, float delta_y) {
    yaw += delta_x;
    pitch += delta_y;
}

void pauli_renderer_cycle_orbital(void) {
    current_family = (current_family + 1) % 4;
}

void pauli_renderer_draw(void) {
    const float family = (float)current_family / 3.0f;
    const float motion =
        0.08f * (sinf(yaw * 5.0f) + cosf(pitch * 5.0f));

    glClearColor(
        0.05f + family * 0.08f,
        0.06f + motion,
        0.08f + (1.0f - family) * 0.08f,
        1.0f
    );
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

void pauli_renderer_stop(void) {
}
