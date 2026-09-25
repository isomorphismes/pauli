#!/usr/bin/env python3

from pathlib import Path
import sys

import sympy as sp

sys.path.insert(
    0,
    str(Path(__file__).resolve().parent),
)

from hydrogen_states import (
    bound_state,
    spdf_states,
)

real_radius = sp.Symbol("radius", real=True)
real_polar_angle = sp.Symbol("polar_angle", real=True)
real_azimuth = sp.Symbol("azimuth", real=True)
pi_f64 = sp.Symbol("PAULI_PI")


def c_identifier(energy_level, angular_degree, axis_component):
    if axis_component < 0:
        axis_text = f"neg_{abs(axis_component)}"
    elif axis_component > 0:
        axis_text = f"pos_{axis_component}"
    else:
        axis_text = "zero"

    return (
        "pauli_hydrogen_"
        f"{energy_level}_"
        f"{angular_degree}_"
        f"{axis_text}"
    )


def sympy_state(energy_level, angular_degree, axis_component):
    expression = bound_state(
        energy_level,
        angular_degree,
        axis_component,
    )._sympy_()

    by_name = {
        symbol.name: symbol
        for symbol in expression.free_symbols
    }

    replacements = {}

    if "radius" in by_name:
        replacements[by_name["radius"]] = real_radius

    if "polar_angle" in by_name:
        replacements[by_name["polar_angle"]] = real_polar_angle

    if "azimuth" in by_name:
        replacements[by_name["azimuth"]] = real_azimuth

    return sp.simplify(
        expression.subs(replacements)
    )


def polar_factorization(
    energy_level,
    angular_degree,
    axis_component,
):
    expression = sympy_state(
        energy_level,
        angular_degree,
        axis_component,
    )

    rotating_phase = (
        axis_component
        * real_azimuth
    )

    signed_amplitude = sp.simplify(
        sp.expand_complex(
            expression
            * sp.exp(
                -sp.I
                * rotating_phase
            )
        )
    )

    imaginary_remainder = sp.simplify(
        sp.im(signed_amplitude)
    )

    if imaginary_remainder != 0:
        raise AssertionError(
            "state did not factor into a real amplitude "
            "and an azimuthal phase: "
            f"{energy_level=} "
            f"{angular_degree=} "
            f"{axis_component=} "
            f"{imaginary_remainder=}"
        )

    signed_amplitude = sp.simplify(
        sp.re(signed_amplitude)
    )

    reconstruction_error = sp.simplify(
        expression
        - signed_amplitude
        * sp.exp(
            sp.I
            * rotating_phase
        )
    )

    if reconstruction_error != 0:
        raise AssertionError(
            "polar factorization did not reconstruct state: "
            f"{energy_level=} "
            f"{angular_degree=} "
            f"{axis_component=} "
            f"{reconstruction_error=}"
        )

    return signed_amplitude, rotating_phase


def c_expression(expression):
    expression = sp.simplify(
        expression.xreplace(
            {
                sp.pi: pi_f64,
            }
        )
    )

    return sp.ccode(
        expression,
        standard="C99",
    )


def render_function(
    energy_level,
    angular_degree,
    axis_component,
):
    signed_amplitude, rotating_phase = polar_factorization(
        energy_level,
        angular_degree,
        axis_component,
    )

    name = c_identifier(
        energy_level,
        angular_degree,
        axis_component,
    )

    return f"""static inline pauli_complex_f64
{name}(
    double radius,
    double polar_angle,
    double azimuth
) {{
    const double signed_amplitude =
        {c_expression(signed_amplitude)};

    pauli_complex_f64 value;
    value.magnitude = fabs(signed_amplitude);
    value.phase = {c_expression(rotating_phase)};

    if (signed_amplitude < 0.0) {{
        value.phase += PAULI_PI;
    }}

    return value;
}}
"""


def render_dispatch(states):
    lines = [
        "static inline pauli_complex_f64",
        "pauli_hydrogen_spdf_f64(",
        "    int energy_level,",
        "    int angular_degree,",
        "    int axis_component,",
        "    double radius,",
        "    double polar_angle,",
        "    double azimuth",
        ") {",
    ]

    for energy_level, angular_degree, axis_component in states:
        name = c_identifier(
            energy_level,
            angular_degree,
            axis_component,
        )

        lines.extend(
            [
                (
                    "    if (energy_level == "
                    f"{energy_level} && "
                    "angular_degree == "
                    f"{angular_degree} && "
                    "axis_component == "
                    f"{axis_component}) {{"
                ),
                (
                    f"        return {name}("
                    "radius, "
                    "polar_angle, "
                    "azimuth);"
                ),
                "    }",
            ]
        )

    lines.extend(
        [
            "    return (pauli_complex_f64){NAN, NAN};",
            "}",
        ]
    )

    return "\n".join(lines)


def render_header():
    states = spdf_states()

    pieces = [
        """#ifndef PAULI_HYDROGEN_SPDF_F64_H
#define PAULI_HYDROGEN_SPDF_F64_H

#include <math.h>

#ifndef PAULI_PI
#define PAULI_PI 3.141592653589793238462643383279502884
#endif

/*
 * Polar Complex F64.
 *
 * The two words are magnitude and phase.  This matches ICK's physical
 * floating complex representation.  Do not replace them with Cartesian
 * storage.
 */
typedef struct {
    double magnitude;
    double phase;
} pauli_complex_f64;
"""
    ]

    for state in states:
        pieces.append(
            render_function(*state)
        )

    pieces.append(
        render_dispatch(states)
    )

    pieces.append("\n#endif\n")

    return "\n".join(pieces)


if __name__ == "__main__":
    sys.stdout.write(
        render_header()
    )
