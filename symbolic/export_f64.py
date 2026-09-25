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

real_radius = sp.Symbol(
    "radius",
    real=True,
)
real_polar_angle = sp.Symbol(
    "polar_angle",
    real=True,
)
real_azimuth = sp.Symbol(
    "azimuth",
    real=True,
)
pi_f64 = sp.Symbol("PAULI_PI")


def c_identifier(
    energy_level,
    angular_degree,
    axis_component,
):
    if axis_component < 0:
        axis_text = (
            f"neg_{abs(axis_component)}"
        )
    elif axis_component > 0:
        axis_text = (
            f"pos_{axis_component}"
        )
    else:
        axis_text = "zero"

    return (
        "pauli_hydrogen_"
        f"{energy_level}_"
        f"{angular_degree}_"
        f"{axis_text}"
    )


def sympy_state(
    energy_level,
    angular_degree,
    axis_component,
):
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
        replacements[
            by_name["radius"]
        ] = real_radius

    if "polar_angle" in by_name:
        replacements[
            by_name["polar_angle"]
        ] = real_polar_angle

    if "azimuth" in by_name:
        replacements[
            by_name["azimuth"]
        ] = real_azimuth

    expression = expression.subs(
        replacements
    )

    return sp.simplify(expression)


def c_component(expression):
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
    expression = sympy_state(
        energy_level,
        angular_degree,
        axis_component,
    )

    expanded = sp.expand_complex(
        expression
    )

    real_expression = sp.simplify(
        sp.re(expanded)
    )
    imaginary_expression = sp.simplify(
        sp.im(expanded)
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
    pauli_complex_f64 value;
    value.real = {c_component(real_expression)};
    value.imaginary = {c_component(imaginary_expression)};
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

    for (
        energy_level,
        angular_degree,
        axis_component,
    ) in states:
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
            (
                "    return "
                "(pauli_complex_f64)"
                "{NAN, NAN};"
            ),
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

#ifndef M_SQRT2
#define M_SQRT2 1.414213562373095048801688724209698079
#endif

typedef struct {
    double real;
    double imaginary;
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

    pieces.append(
        "\n#endif\n"
    )

    return "\n".join(pieces)


if __name__ == "__main__":
    sys.stdout.write(
        render_header()
    )
