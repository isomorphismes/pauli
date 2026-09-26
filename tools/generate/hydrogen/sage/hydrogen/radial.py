from sage.all import (
    QQ,
    exp,
    factorial,
    gen_laguerre,
    sqrt,
)

from .coordinates import radius
from .quantum_numbers import check_radial_numbers


def radial_mode(
    energy_level,
    angular_degree,
):
    check_radial_numbers(
        energy_level,
        angular_degree,
    )

    scaled_radius = 2 * radius / energy_level

    normalization = sqrt(
        (QQ(2) / energy_level) ** 3
        * factorial(
            energy_level
            - angular_degree
            - 1
        )
        / (
            2
            * energy_level
            * factorial(
                energy_level
                + angular_degree
            )
        )
    )

    decay = exp(
        -radius / energy_level
    )

    radial_power = (
        scaled_radius**angular_degree
    )

    polynomial = gen_laguerre(
        energy_level - angular_degree - 1,
        2 * angular_degree + 1,
        scaled_radius,
    )

    return (
        normalization
        * decay
        * radial_power
        * polynomial
    ).simplify_full()
