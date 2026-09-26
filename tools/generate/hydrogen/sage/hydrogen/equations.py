from sage.all import (
    QQ,
    diff,
    sin,
)

from .coordinates import (
    azimuth,
    polar_angle,
    radius,
)
from .radial import radial_mode
from .state import (
    bound_state,
    bound_state_energy,
)
from .angular import angular_mode
from .symbolic import simplify_identity


def radial_laplacian(
    radial,
    angular_degree,
):
    return (
        diff(radial, radius, 2)
        + 2 / radius * diff(radial, radius)
        - (
            angular_degree
            * (angular_degree + 1)
            / radius**2
            * radial
        )
    )


def sphere_laplacian(expression):
    return (
        diff(
            sin(polar_angle)
            * diff(expression, polar_angle),
            polar_angle,
        )
        / sin(polar_angle)
        + diff(expression, azimuth, 2)
        / sin(polar_angle) ** 2
    )


def spatial_laplacian(expression):
    radial_part = (
        diff(expression, radius, 2)
        + 2 / radius
        * diff(expression, radius)
    )
    angular_part = (
        sphere_laplacian(expression)
        / radius**2
    )

    return radial_part + angular_part


def radial_equation_residual(
    energy_level,
    angular_degree,
):
    radial = radial_mode(
        energy_level,
        angular_degree,
    )
    energy = bound_state_energy(energy_level)

    return simplify_identity(
        -QQ(1) / 2
        * radial_laplacian(
            radial,
            angular_degree,
        )
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

    return simplify_identity(
        sphere_laplacian(angular)
        + (
            angular_degree
            * (angular_degree + 1)
            * angular
        )
    )


def stationary_equation_residual(
    energy_level,
    angular_degree,
    axis_component,
):
    state = bound_state(
        energy_level,
        angular_degree,
        axis_component,
    )
    energy = bound_state_energy(energy_level)

    return simplify_identity(
        -QQ(1) / 2
        * spatial_laplacian(state)
        - state / radius
        - energy * state
    )
