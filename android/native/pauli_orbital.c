#include "pauli_orbital.h"

#include <math.h>

static const float pi_value = 3.14159265358979323846f;

static struct pauli_orbital_sample sample_1s(float radius) {
    return (struct pauli_orbital_sample) {
        .density = expf(-2.0f * radius) / pi_value,
        .negative_phase = 0
    };
}

static struct pauli_orbital_sample sample_2p_x(
    float x,
    float radius
) {
    return (struct pauli_orbital_sample) {
        .density =
            x * x *
            expf(-radius) /
            (32.0f * pi_value),
        .negative_phase = x < 0.0f
    };
}

static struct pauli_orbital_sample sample_3d_xy(
    float x,
    float y,
    float radius
) {
    const float shape = x * y;

    return (struct pauli_orbital_sample) {
        .density =
            shape * shape *
            expf((-2.0f / 3.0f) * radius),
        .negative_phase = shape < 0.0f
    };
}

static struct pauli_orbital_sample sample_4f_xyz(
    float x,
    float y,
    float z,
    float radius
) {
    const float shape = x * y * z;

    return (struct pauli_orbital_sample) {
        .density =
            shape * shape *
            expf(-0.5f * radius),
        .negative_phase = shape < 0.0f
    };
}

struct pauli_orbital_sample pauli_orbital_sample_at(
    enum pauli_orbital orbital,
    float x,
    float y,
    float z
) {
    const float radius = sqrtf(x * x + y * y + z * z);

    switch (orbital) {
        case PAULI_ORBITAL_1S:
            return sample_1s(radius);

        case PAULI_ORBITAL_2P_X:
            return sample_2p_x(x, radius);

        case PAULI_ORBITAL_3D_XY:
            return sample_3d_xy(x, y, radius);

        case PAULI_ORBITAL_4F_XYZ:
        default:
            return sample_4f_xyz(x, y, z, radius);
    }
}

enum pauli_orbital pauli_orbital_next(enum pauli_orbital orbital) {
    return (enum pauli_orbital)(
        ((int)orbital + 1) %
        (int)PAULI_ORBITAL_COUNT
    );
}

const char *pauli_orbital_name(enum pauli_orbital orbital) {
    switch (orbital) {
        case PAULI_ORBITAL_1S:
            return "1s";
        case PAULI_ORBITAL_2P_X:
            return "2p_x";
        case PAULI_ORBITAL_3D_XY:
            return "3d_xy";
        case PAULI_ORBITAL_4F_XYZ:
        default:
            return "4f_xyz";
    }
}
