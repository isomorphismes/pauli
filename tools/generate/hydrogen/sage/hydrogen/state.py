"""Start reading here.

This file is the conceptual center of the hydrogen-state code.

There is not one procedural "main" function that runs the whole directory.
Instead, the generator and checking scripts ask for hydrogen states and related
quantities.  A bound state is the natural place to begin because it shows the
main construction in one place:

    energy level n
          |
          +--> radial_mode(n, l) --------+
          |                              |
          +--> angular_mode(l, m) -------+--> bound_state(n, l, m)
                                               = radial * angular

Read the implementation in this order:

    1. state.py
       See what a complete state is and which pieces make it.

    2. radial.py
       See how the radius-dependent part is constructed.

    3. angular.py
       See how the angle-dependent part is constructed.

    4. equations.py
       See how the radial part, angular part, and complete state are checked
       against their differential equations.

    5. inner_products.py
       See how radial and angular modes are compared for normalization and
       orthogonality.

    6. catalogue.py
       See which allowed (n, l, m) combinations are generated.

Supporting files can usually be read later:

    quantum_numbers.py
        Rules saying which n, l, and m values are allowed.

    coordinates.py
        The shared radius and angle symbols.

    symbolic.py
        Common symbolic simplification used by checks.

How the rest of the program uses this code:

    hydrogen_states.py
        Keeps the old public import names and forwards them into these smaller
        files.

    check_hydrogen_states.py
        Enumerates states and asks equations.py to verify the radial, angular,
        and full stationary equations.

    export_polar_f64.py
        Enumerates states, calls bound_state(), and converts the resulting
        symbolic expressions into the generated runtime representation.

So this file is a reading entry point, not a process entry point.
"""

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

    # Separation of variables is the main structural fact exposed here:
    # the complete spatial state is the product of those two pieces.
    return (
        radial * angular
    ).simplify_full()
