#!/usr/bin/env python3

from pathlib import Path
import sys

sys.path.insert(
    0,
    str(Path(__file__).resolve().parent),
)

from hydrogen_states import (
    angular_equation_residual,
    angular_modes,
    radial_equation_residual,
    simplify_identity,
    spdf_states,
    stationary_equation_residual,
    unique_radial_modes,
)


def require_zero(name, expression):
    reduced = simplify_identity(expression)
    if reduced != 0:
        raise AssertionError(
            f"{name} did not reduce to zero: {reduced}"
        )


states = spdf_states()
radial_modes = unique_radial_modes()
sphere_modes = angular_modes()

if len(states) != 30:
    raise AssertionError(
        "expected 30 spatial states through s, p, d, f; "
        f"got {len(states)}"
    )

for energy_level, angular_degree in radial_modes:
    require_zero(
        (
            "radial equation "
            f"energy_level={energy_level} "
            f"angular_degree={angular_degree}"
        ),
        radial_equation_residual(
            energy_level,
            angular_degree,
        ),
    )

for angular_degree, axis_component in sphere_modes:
    require_zero(
        (
            "sphere equation "
            f"angular_degree={angular_degree} "
            f"axis_component={axis_component}"
        ),
        angular_equation_residual(
            angular_degree,
            axis_component,
        ),
    )

for energy_level, angular_degree, axis_component in states:
    require_zero(
        (
            "stationary hydrogen equation "
            f"energy_level={energy_level} "
            f"angular_degree={angular_degree} "
            f"axis_component={axis_component}"
        ),
        stationary_equation_residual(
            energy_level,
            angular_degree,
            axis_component,
        ),
    )

print(
    "PASS: "
    f"{len(states)} canonical Sage states through s, p, d, f; "
    "radial, spherical, and full stationary equations"
)
