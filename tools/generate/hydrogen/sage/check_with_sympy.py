#!/usr/bin/env python3

import sympy as sp
from sympy.functions.special.spherical_harmonics import Ynm
from sympy.simplify.fu import fu

radius = sp.symbols(
    "radius",
    positive=True,
    real=True,
)
polar_angle = sp.symbols(
    "polar_angle",
    positive=True,
    real=True,
)
azimuth = sp.symbols(
    "azimuth",
    real=True,
)


def bound_state_energy(energy_level):
    return -sp.Rational(
        1,
        2 * energy_level**2,
    )


def radial_mode(energy_level, angular_degree):
    scaled_radius = 2 * radius / energy_level
    normalization = sp.sqrt(
        sp.Rational(2, energy_level) ** 3
        * sp.factorial(
            energy_level - angular_degree - 1
        )
        / (
            2
            * energy_level
            * sp.factorial(
                energy_level + angular_degree
            )
        )
    )

    return sp.simplify(
        normalization
        * sp.exp(-radius / energy_level)
        * scaled_radius**angular_degree
        * sp.assoc_laguerre(
            energy_level - angular_degree - 1,
            2 * angular_degree + 1,
            scaled_radius,
        )
    )


def angular_mode(
    angular_degree,
    axis_component,
):
    return sp.expand_func(
        Ynm(
            angular_degree,
            axis_component,
            polar_angle,
            azimuth,
        )
    )


def radial_equation_residual(
    energy_level,
    angular_degree,
):
    radial = radial_mode(
        energy_level,
        angular_degree,
    )
    energy = bound_state_energy(
        energy_level
    )

    radial_laplacian = (
        sp.diff(radial, radius, 2)
        + 2 / radius * sp.diff(
            radial,
            radius,
        )
        - angular_degree
        * (angular_degree + 1)
        / radius**2
        * radial
    )

    return sp.simplify(
        -sp.Rational(1, 2)
        * radial_laplacian
        - radial / radius
        - energy * radial
    )


def angular_equation_residual(
    angular_degree,
    axis_component,
):
    angular = angular_mode(
        angular_degree,
        axis_component,
    )

    sphere_laplacian = (
        sp.diff(
            sp.sin(polar_angle)
            * sp.diff(
                angular,
                polar_angle,
            ),
            polar_angle,
        )
        / sp.sin(polar_angle)
        + sp.diff(
            angular,
            azimuth,
            2,
        )
        / sp.sin(polar_angle) ** 2
    )

    return sp.simplify(
        fu(
            sp.trigsimp(
                sp.expand(
                    sphere_laplacian
                    + angular_degree
                    * (angular_degree + 1)
                    * angular
                )
            )
        )
    )


def radial_inner_product(
    first_energy_level,
    second_energy_level,
    angular_degree,
):
    first = radial_mode(
        first_energy_level,
        angular_degree,
    )
    second = radial_mode(
        second_energy_level,
        angular_degree,
    )

    return sp.simplify(
        sp.integrate(
            first
            * second
            * radius**2,
            (
                radius,
                0,
                sp.oo,
            ),
        )
    )


def angular_inner_product(
    first_angular_degree,
    first_axis_component,
    second_angular_degree,
    second_axis_component,
):
    first = angular_mode(
        first_angular_degree,
        first_axis_component,
    )
    second = angular_mode(
        second_angular_degree,
        second_axis_component,
    )

    after_azimuth = sp.integrate(
        sp.conjugate(first)
        * second
        * sp.sin(polar_angle),
        (
            azimuth,
            0,
            2 * sp.pi,
        ),
    )

    return sp.simplify(
        sp.integrate(
            sp.simplify(after_azimuth),
            (
                polar_angle,
                0,
                sp.pi,
            ),
        )
    )


def unique_radial_modes():
    return [
        (energy_level, angular_degree)
        for energy_level in range(1, 5)
        for angular_degree in range(
            min(energy_level - 1, 3) + 1
        )
    ]


def angular_modes():
    return [
        (angular_degree, axis_component)
        for angular_degree in range(4)
        for axis_component in range(
            -angular_degree,
            angular_degree + 1,
        )
    ]


def spdf_states():
    return [
        (
            energy_level,
            angular_degree,
            axis_component,
        )
        for energy_level in range(1, 5)
        for angular_degree in range(
            min(energy_level - 1, 3) + 1
        )
        for axis_component in range(
            -angular_degree,
            angular_degree + 1,
        )
    ]


expected_one_one = (
    -sp.sqrt(6)
    * sp.exp(sp.I * azimuth)
    * sp.sin(polar_angle)
    / (4 * sp.sqrt(sp.pi))
)

if sp.simplify(
    angular_mode(1, 1)
    - expected_one_one
) != 0:
    raise AssertionError(
        "unexpected spherical-harmonic phase convention"
    )

states = spdf_states()
radial_modes = unique_radial_modes()
sphere_modes = angular_modes()

if len(states) != 30:
    raise AssertionError(
        f"expected 30 states; got {len(states)}"
    )

for energy_level, angular_degree in radial_modes:
    radial_residual = radial_equation_residual(
        energy_level,
        angular_degree,
    )

    if radial_residual != 0:
        raise AssertionError(
            "SymPy radial equation failed: "
            f"{energy_level=} "
            f"{angular_degree=} "
            f"{radial_residual=}"
        )

    normalization = radial_inner_product(
        energy_level,
        energy_level,
        angular_degree,
    )

    if normalization != 1:
        raise AssertionError(
            "SymPy radial normalization failed: "
            f"{energy_level=} "
            f"{angular_degree=} "
            f"{normalization=}"
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
            product = radial_inner_product(
                first_energy_level,
                second_energy_level,
                angular_degree,
            )

            if product != 0:
                raise AssertionError(
                    "SymPy radial orthogonality failed: "
                    f"{first_energy_level=} "
                    f"{second_energy_level=} "
                    f"{angular_degree=} "
                    f"{product=}"
                )

for angular_degree, axis_component in sphere_modes:
    angular_residual = (
        angular_equation_residual(
            angular_degree,
            axis_component,
        )
    )

    if angular_residual != 0:
        raise AssertionError(
            "SymPy sphere equation failed: "
            f"{angular_degree=} "
            f"{axis_component=} "
            f"{angular_residual=}"
        )

for first_index, first_mode in enumerate(
    sphere_modes
):
    for second_index in range(
        first_index,
        len(sphere_modes),
    ):
        second_mode = sphere_modes[
            second_index
        ]

        product = angular_inner_product(
            first_mode[0],
            first_mode[1],
            second_mode[0],
            second_mode[1],
        )

        expected = (
            1
            if first_mode == second_mode
            else 0
        )

        if sp.simplify(
            product - expected
        ) != 0:
            raise AssertionError(
                "SymPy angular inner product failed: "
                f"{first_mode=} "
                f"{second_mode=} "
                f"{product=}"
            )

print(
    "PASS: "
    f"{len(states)} independent SymPy states "
    "through s, p, d, f; equations, "
    "normalization, and orthogonality"
)
