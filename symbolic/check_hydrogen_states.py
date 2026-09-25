#!/usr/bin/env python3

from pathlib import Path
import sys

sys.path.insert(
    0,
    str(Path(__file__).resolve().parent),
)

from hydrogen_states import (
    angular_equation_residual,
    angular_inner_product,
    angular_modes,
    radial_equation_residual,
    radial_inner_product,
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


def require_one(name, expression):
    require_zero(
        name,
        expression - 1,
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

    require_one(
        (
            "radial normalization "
            f"energy_level={energy_level} "
            f"angular_degree={angular_degree}"
        ),
        radial_inner_product(
            energy_level,
            energy_level,
            angular_degree,
        ),
    )

for angular_degree in range(4):
    energy_levels = range(
        angular_degree + 1,
        5,
    )

    for first_energy_level in energy_levels:
        for second_energy_level in range(
            first_energy_level + 1,
            5,
        ):
            require_zero(
                (
                    "radial orthogonality "
                    f"first_energy_level={first_energy_level} "
                    f"second_energy_level={second_energy_level} "
                    f"angular_degree={angular_degree}"
                ),
                radial_inner_product(
                    first_energy_level,
                    second_energy_level,
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

for first_index, first_mode in enumerate(sphere_modes):
    for second_index in range(
        first_index,
        len(sphere_modes),
    ):
        second_mode = sphere_modes[second_index]

        product = angular_inner_product(
            first_mode[0],
            first_mode[1],
            second_mode[0],
            second_mode[1],
        )

        if first_mode == second_mode:
            require_one(
                (
                    "angular normalization "
                    f"mode={first_mode}"
                ),
                product,
            )
        else:
            require_zero(
                (
                    "angular orthogonality "
                    f"first_mode={first_mode} "
                    f"second_mode={second_mode}"
                ),
                product,
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
    f"{len(states)} exact Sage states through s, p, d, f; "
    "equations, normalization, and orthogonality"
)
