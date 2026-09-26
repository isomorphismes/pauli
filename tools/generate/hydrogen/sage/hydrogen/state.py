"""Compose complete hydrogen bound states from radial and angular modes."""

from sage.all import QQ

from .angular import angular_mode
from .quantum_numbers import (
    check_energy_level,
    check_state_numbers,
)
from .radial import radial_mode


def bound_state_energy(energy_level):
    """Return the energy shared by all states with this energy level."""
    check_energy_level(energy_level)
    return -QQ(1) / (2 * energy_level**2)


def bound_state(
    energy_level,
    angular_degree,
    axis_component,
):
    """Build one complete hydrogen state from its radial and angular parts."""
    check_state_numbers(
        energy_level,
        angular_degree,
        axis_component,
    )

    # The radial part depends on n and l, but not m.
    radial = radial_mode(
        energy_level,
        angular_degree,
    )

    # The angular part depends on l and m, but not n.
    angular = angular_mode(
        angular_degree,
        axis_component,
    )

    # Separation of variables: the complete spatial state is their product.
    return (
        radial * angular
    ).simplify_full()
