#include "pauli_renderer.h"

#include <stdint.h>

#include "pauli_gles_image.h"
#include "pauli_orbital.h"
#include "pauli_volume_image.h"

/*
 * This file coordinates the viewer.
 *
 * Orbital mathematics lives in pauli_orbital.c.
 * Color choices live in pauli_color.c.
 * Ray integration lives in pauli_volume_image.c.
 * OpenGL ES presentation lives in pauli_gles_image.c.
 */

static enum pauli_orbital current_orbital =
    PAULI_ORBITAL_2P_X;

static float yaw = 0.0f;
static float pitch = 0.0f;

static int pixels_dirty = 1;

static uint8_t pixels[
    PAULI_VOLUME_IMAGE_SIDE *
    PAULI_VOLUME_IMAGE_SIDE *
    3
];

static void render_current_orbital(void) {
    pauli_volume_render_image(
        current_orbital,
        yaw,
        pitch,
        pixels
    );

    pauli_gles_image_upload(
        PAULI_VOLUME_IMAGE_SIDE,
        pixels
    );

    pixels_dirty = 0;
}

int pauli_renderer_start(
    int width,
    int height,
    int gles_major
) {
    if (gles_major < 2) {
        return 0;
    }

    pauli_volume_render_image(
        current_orbital,
        yaw,
        pitch,
        pixels
    );

    if (!pauli_gles_image_start(
            width,
            height,
            PAULI_VOLUME_IMAGE_SIDE,
            pixels
        )) {
        return 0;
    }

    pixels_dirty = 0;
    return 1;
}

void pauli_renderer_resize(
    int width,
    int height
) {
    pauli_gles_image_resize(
        width,
        height
    );
}

void pauli_renderer_drag(
    float delta_x,
    float delta_y
) {
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
    current_orbital =
        pauli_orbital_next(
            current_orbital
        );

    pixels_dirty = 1;
}

void pauli_renderer_draw(void) {
    if (pixels_dirty) {
        render_current_orbital();
    }

    pauli_gles_image_draw();
}

void pauli_renderer_stop(void) {
    pauli_gles_image_stop();
    pixels_dirty = 1;
}
