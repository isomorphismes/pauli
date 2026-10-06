#ifndef PAULI_ORBITAL_H
#define PAULI_ORBITAL_H

#include <stddef.h>
#include "hydrogen_spdf_f64.h"

enum pauli_hydrogen_basis {
    PAULI_SPHERICAL,
    PAULI_REAL_COSINE,
    PAULI_REAL_SINE
};

/* n, ℓ, m respectively. For real bases m is the positive paired component. */
struct pauli_hydrogen_state {
    int energy_level;
    int angular_degree;
    int axis_component;
    enum pauli_hydrogen_basis basis;
};

struct pauli_orbital_demo {
    const char *name;
    struct pauli_hydrogen_state state;
};

struct pauli_orbital_sample {
    pauli_complex_f64 amplitude;
    double density;
    int negative_phase;
};

struct pauli_orbital_sample pauli_orbital_sample_at(
    const struct pauli_hydrogen_state *state,
    double x,
    double y,
    double z
);

int pauli_hydrogen_state_valid(const struct pauli_hydrogen_state *state);
size_t pauli_orbital_demo_count(void);
const struct pauli_orbital_demo *pauli_orbital_demo_at(size_t index);
int pauli_orbital_demo_index(const struct pauli_hydrogen_state *state);

#endif
