from sage.all import (
    infinity,
    integral,
    pi,
    sin,
)

from .angular import (
    angular_conjugate,
    angular_mode,
)
from .coordinates import (
    azimuth,
    polar_angle,
    radius,
)
from .radial import radial_mode
from .symbolic import simplify_identity


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

    return simplify_identity(
        integral(
            first * second * radius**2,
            radius,
            0,
            infinity,
        )
    )


def angular_inner_product(
    first_angular_degree,
    first_axis_component,
    second_angular_degree,
    second_axis_component,
):
    first_conjugate = angular_conjugate(
        first_angular_degree,
        first_axis_component,
    )
    second = angular_mode(
        second_angular_degree,
        second_axis_component,
    )

    after_azimuth = integral(
        first_conjugate * second,
        azimuth,
        0,
        2 * pi,
    )

    return simplify_identity(
        integral(
            after_azimuth * sin(polar_angle),
            polar_angle,
            0,
            pi,
        )
    )
