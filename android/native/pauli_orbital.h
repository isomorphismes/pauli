#ifndef PAULI_ORBITAL_H
#define PAULI_ORBITAL_H

enum pauli_orbital {
    PAULI_ORBITAL_1S = 0,
    PAULI_ORBITAL_2P_X,
    PAULI_ORBITAL_3D_XY,
    PAULI_ORBITAL_4F_XYZ,
    PAULI_ORBITAL_COUNT
};

struct pauli_orbital_sample {
    float density;
    int negative_phase;
};

struct pauli_orbital_sample pauli_orbital_sample_at(
    enum pauli_orbital orbital,
    float x,
    float y,
    float z
);

enum pauli_orbital pauli_orbital_next(enum pauli_orbital orbital);

const char *pauli_orbital_name(enum pauli_orbital orbital);

#endif
