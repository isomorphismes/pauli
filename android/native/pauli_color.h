#ifndef PAULI_COLOR_H
#define PAULI_COLOR_H

#include <stdint.h>

struct pauli_rgb {
    float red;
    float green;
    float blue;
};

struct pauli_rgb pauli_background_color(void);

struct pauli_rgb pauli_phase_color(int negative_phase);

struct pauli_rgb pauli_color_add(
    struct pauli_rgb left,
    struct pauli_rgb right
);

struct pauli_rgb pauli_color_scale(
    struct pauli_rgb color,
    float scale
);

struct pauli_rgb pauli_finish_volume_color(
    struct pauli_rgb accumulated,
    float gain
);

void pauli_color_to_rgb8(
    struct pauli_rgb color,
    uint8_t output[3]
);

#endif
