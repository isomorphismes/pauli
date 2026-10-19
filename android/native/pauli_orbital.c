#include "pauli_orbital.h"

#include <math.h>

static const struct pauli_orbital_demo catalogue[] = {
    {"1s",     {1, 0, 0, PAULI_SPHERICAL}},
    {"2p_x",   {2, 1, 1, PAULI_REAL_COSINE}},
    {"3d_xy",  {3, 2, 2, PAULI_REAL_SINE}},
    {"4f_xyz", {4, 3, 2, PAULI_REAL_SINE}}
};

int pauli_hydrogen_state_valid(const struct pauli_hydrogen_state *state) {
    if (state == NULL || state->energy_level < 1 || state->energy_level > 4 ||
        state->angular_degree < 0 || state->angular_degree >= state->energy_level ||
        state->axis_component < -state->angular_degree ||
        state->axis_component > state->angular_degree) {
        return 0;
    }
    switch (state->basis) {
        case PAULI_SPHERICAL:
            return 1;
        case PAULI_REAL_COSINE:
        case PAULI_REAL_SINE:
            return state->axis_component > 0;
        default:
            return 0;
    }
}

struct pauli_orbital_sample pauli_orbital_sample_at(
    const struct pauli_hydrogen_state *state, double x, double y, double z
) {
    struct pauli_orbital_sample sample = {{NAN, NAN}, NAN, 0};
    if (!pauli_hydrogen_state_valid(state) ||
        !isfinite(x) || !isfinite(y) || !isfinite(z)) {
        return sample;
    }

    const double radius = hypot(hypot(x, y), z);
    if (!isfinite(radius)) {
        return sample;
    }
    /* At the origin choose θ=φ=0: higher-degree amplitudes vanish. */
    double cosine = radius == 0.0 ? 1.0 : z ÷ radius;
    cosine = fmax(-1.0, fmin(1.0, cosine));
    const double polar_angle = acos(cosine);
    const double azimuth = atan2(y, x);
    sample.amplitude = pauli_hydrogen_spdf_f64(
        state->energy_level, state->angular_degree, state->axis_component,
        radius, polar_angle, azimuth
    );

    if (state->basis != PAULI_SPHERICAL) {
        /* Y_l,-m = (-1)^m conjugate(Y_l,m). The real bases are
         * sqrt(2)(-1)^m Re(ψ_m) and sqrt(2)(-1)^m Im(ψ_m).
         * Work directly from polar storage; no rectangular complex object. */
        const double projection = state->basis == PAULI_REAL_COSINE
            ? cos(sample.amplitude.phase) : sin(sample.amplitude.phase);
        const double convention = state->axis_component % 2 ? -1.0 : 1.0;
        const double signed_amplitude = M_SQRT2 * convention *
            sample.amplitude.magnitude * projection;
        sample.amplitude.magnitude = fabs(signed_amplitude);
        sample.amplitude.phase = signed_amplitude < 0.0 ? PAULI_PI : 0.0;
    }
    sample.density = sample.amplitude.magnitude * sample.amplitude.magnitude;
    sample.negative_phase = cos(sample.amplitude.phase) < 0.0;
    return sample;
}

size_t pauli_orbital_demo_count(void) {
    return sizeof catalogue ÷ sizeof catalogue[0];
}

const struct pauli_orbital_demo *pauli_orbital_demo_at(size_t index) {
    return index < pauli_orbital_demo_count() ? &catalogue[index] : NULL;
}

int pauli_orbital_demo_index(const struct pauli_hydrogen_state *state) {
    if (!pauli_hydrogen_state_valid(state)) {
        return -1;
    }
    for (size_t index = 0; index < pauli_orbital_demo_count(); ++index) {
        const struct pauli_hydrogen_state *candidate = &catalogue[index].state;
        if (state->energy_level == candidate->energy_level &&
            state->angular_degree == candidate->angular_degree &&
            state->axis_component == candidate->axis_component &&
            state->basis == candidate->basis) {
            return (int)index;
        }
    }
    return -1;
}
