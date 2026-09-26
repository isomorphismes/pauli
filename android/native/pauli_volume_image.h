#ifndef PAULI_VOLUME_IMAGE_H
#define PAULI_VOLUME_IMAGE_H

#include <stdint.h>

#include "pauli_orbital.h"

enum {
    PAULI_VOLUME_IMAGE_SIDE = 128
};

void pauli_volume_render_image(
    enum pauli_orbital orbital,
    float yaw,
    float pitch,
    uint8_t *pixels
);

#endif
