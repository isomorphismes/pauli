#include "pauli_color.h"

#include <math.h>

static const struct pauli_rgb background = {
    .red = 0.075f,
    .green = 0.090f,
    .blue = 0.115f
};

static const struct pauli_rgb positive_phase = {
    .red = 0.18f,
    .green = 0.68f,
    .blue = 1.00f
};

static const struct pauli_rgb negative_phase = {
    .red = 1.00f,
    .green = 0.35f,
    .blue = 0.12f
};

static float clamp_channel(float value) {
    if (value < 0.0f) {
        return 0.0f;
    }
    if (value > 1.0f) {
        return 1.0f;
    }
    return value;
}

static float tone_map_channel(float value, float gain) {
    return 1.0f - expf(-gain * value);
}

struct pauli_rgb pauli_background_color(void) {
    return background;
}

struct pauli_rgb pauli_phase_color(int negative_phase_value) {
    return negative_phase_value
        ? negative_phase
        : positive_phase;
}

struct pauli_rgb pauli_color_add(
    struct pauli_rgb left,
    struct pauli_rgb right
) {
    return (struct pauli_rgb) {
        .red = left.red + right.red,
        .green = left.green + right.green,
        .blue = left.blue + right.blue
    };
}

struct pauli_rgb pauli_color_scale(
    struct pauli_rgb color,
    float scale
) {
    return (struct pauli_rgb) {
        .red = color.red * scale,
        .green = color.green * scale,
        .blue = color.blue * scale
    };
}

struct pauli_rgb pauli_finish_volume_color(
    struct pauli_rgb accumulated,
    float gain
) {
    return (struct pauli_rgb) {
        .red =
            background.red +
            tone_map_channel(accumulated.red, gain),
        .green =
            background.green +
            tone_map_channel(accumulated.green, gain),
        .blue =
            background.blue +
            tone_map_channel(accumulated.blue, gain)
    };
}

void pauli_color_to_rgb8(
    struct pauli_rgb color,
    uint8_t output[3]
) {
    output[0] = (uint8_t)floorf(
        255.0f * clamp_channel(color.red) + 0.5f
    );
    output[1] = (uint8_t)floorf(
        255.0f * clamp_channel(color.green) + 0.5f
    );
    output[2] = (uint8_t)floorf(
        255.0f * clamp_channel(color.blue) + 0.5f
    );
}
