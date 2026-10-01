#ifndef PAULI_GLES_IMAGE_H
#define PAULI_GLES_IMAGE_H

#include <stdint.h>

int pauli_gles_image_start(
    int width,
    int height,
    int image_side,
    const uint8_t *pixels
);

void pauli_gles_image_resize(int width, int height);

void pauli_gles_image_upload(
    int image_side,
    const uint8_t *pixels
);

void pauli_gles_image_draw(void);

void pauli_gles_image_stop(void);

#endif
