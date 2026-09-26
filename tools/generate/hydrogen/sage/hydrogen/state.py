from sage.all import QQ

from .angular import angular_mode
from .quantum_numbers import (
    check_energy_level,
    check_state_numbers,
)
from .radial import radial_mode


def bound_state_energy(energy_level):
    check_energy_level(energy_level)
    return -QQ(1) / (2 * energy_level**2)


def bound_state(
    energy_level,
    angular_degree,
    axis_component,
):
    check_state_numbers(
        energy_level,
        angular_degree,
        axis_component,
    )

    radial = radial_mode(
        energy_level,
        angular_degree,
    )
    angular = angular_mode(
        angular_degree,
        axis_component,
    )

    return (
        radial * angular
    ).simplify_full()
