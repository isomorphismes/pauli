"""Public Sage interface for hydrogen bound states.

The implementation is organized by mathematical role:

- coordinates: shared spherical coordinates
- quantum_numbers: validity rules for n, l, and m
- radial / angular: the two separable mode families
- state: energy and the product of radial and angular modes
- equations: radial, spherical, and full spatial equations
- inner_products: normalization and orthogonality operations
- catalogue: the shared enumeration of s, p, d, f states
"""

from hydrogen.angular import (
    angular_conjugate,
    angular_mode,
)
from hydrogen.catalogue import (
    angular_modes,
    spdf_states,
    unique_radial_modes,
)
from hydrogen.coordinates import (
    azimuth,
    polar_angle,
    radius,
)
from hydrogen.equations import (
    angular_equation_residual,
    radial_equation_residual,
    stationary_equation_residual,
)
from hydrogen.inner_products import (
    angular_inner_product,
    radial_inner_product,
)
from hydrogen.quantum_numbers import (
    check_state_numbers,
)
from hydrogen.radial import radial_mode
from hydrogen.state import (
    bound_state,
    bound_state_energy,
)
from hydrogen.symbolic import simplify_identity

__all__ = [
    "angular_conjugate",
    "angular_equation_residual",
    "angular_inner_product",
    "angular_mode",
    "angular_modes",
    "azimuth",
    "bound_state",
    "bound_state_energy",
    "check_state_numbers",
    "polar_angle",
    "radial_equation_residual",
    "radial_inner_product",
    "radial_mode",
    "radius",
    "simplify_identity",
    "spdf_states",
    "stationary_equation_residual",
    "unique_radial_modes",
]
