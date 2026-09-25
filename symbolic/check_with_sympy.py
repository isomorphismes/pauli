#!/usr/bin/env python3

import sympy as sp
from sympy.functions.special.spherical_harmonics import Ynm
from sympy.simplify.fu import fu

radius = sp.symbols("radius", positive=True, real=True)
polar_angle = sp.symbols("polar_angle", positive=True, real=True)
azimuth = sp.symbols("azimuth", real=True)


def bound_state_energy(energy_level):
    return -sp.Rational(1, 2 * energy_level**2)


def radial_mode(energy_level, angular_degree):
    scaled_radius = 2 * radius / energy_level
    normalization = sp.sqrt(
        sp.Rational(2, energy_level) ** 3
        * sp.factorial(energy_level - angular_degree - 1)
        / (
            2
            * energy_level
            * sp.factorial(energy_level + angular_degree)
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


def angular_mode(angular_degree, axis_component):
    return sp.expand_func(
        Ynm(
            angular_degree,
            axis_component,
            polar_angle,
            azimuth,
        )
    )


def radial_equation_residual(energy_level, angular_degree):
    radial = radial_mode(energy_level, angular_degree)
    energy = bound_state_energy(energy_level)

    radial_laplacian = (
        sp.diff(radial, radius, 2)
        + 2 / radius * sp.diff(radial, radius)
        - angular_degree * (angular_degree + 1) / radius**2 * radial
    )

    return sp.simplify(
        -sp.Rational(1, 2) * radial_laplacian
        - radial / radius
        - energy * radial
    )


def angular_equation_residual(angular_degree, axis_component):
    angular = angular_mode(angular_degree, axis_component)

    sphere_laplacian = (
        sp.diff(
            sp.sin(polar_angle) * sp.diff(angular, polar_angle),
            polar_angle,
        )
        / sp.sin(polar_angle)
        + sp.diff(angular, azimuth, 2) / sp.sin(polar_angle) ** 2
    )

    return sp.simplify(
        fu(
            sp.trigsimp(
                sp.expand(
                    sphere_laplacian
                    + angular_degree * (angular_degree + 1) * angular
                )
            )
        )
    )


def spdf_states():
    states = []

    for energy_level in range(1, 5):
        for angular_degree in range(min(energy_level - 1, 3) + 1):
            for axis_component in range(-angular_degree, angular_degree + 1):
                states.append(
                    (
                        energy_level,
                        angular_degree,
                        axis_component,
                    )
                )

    return states


states = spdf_states()

if len(states) != 30:
    raise AssertionError(f"expected 30 states; got {len(states)}")

for energy_level, angular_degree, axis_component in states:
    radial_residual = radial_equation_residual(
        energy_level,
        angular_degree,
    )
    if radial_residual != 0:
        raise AssertionError(
            "SymPy radial equation failed: "
            f"{energy_level=} {angular_degree=} "
            f"{radial_residual=}"
        )

    angular_residual = angular_equation_residual(
        angular_degree,
        axis_component,
    )
    if angular_residual != 0:
        raise AssertionError(
            "SymPy sphere equation failed: "
            f"{angular_degree=} {axis_component=} "
            f"{angular_residual=}"
        )

print(f"PASS: {len(states)} independent SymPy states through s, p, d, f")
