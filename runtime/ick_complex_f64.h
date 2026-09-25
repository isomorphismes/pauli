#ifndef PAULI_ICK_COMPLEX_F64_H
#define PAULI_ICK_COMPLEX_F64_H

/*
 * Compile this header only with ICK.
 *
 * ICK stores floating complex values physically as:
 *
 *     magnitude, phase
 *
 * This adapter writes that complete physical object image directly. It does
 * not construct a Cartesian pair and convert it afterward.
 */

_Static_assert(
    sizeof(double _Complex)
        == 2 * sizeof(double),
    "ICK double _Complex must occupy two F64 slots"
);

static inline double _Complex
pauli_ick_complex_f64_from_polar(
    double magnitude,
    double phase
)
{
    const double physical_slots[2] = {
        magnitude,
        phase,
    };

    double _Complex value;

    __builtin_memcpy(
        &value,
        physical_slots,
        sizeof value
    );

    return value;
}

#endif
