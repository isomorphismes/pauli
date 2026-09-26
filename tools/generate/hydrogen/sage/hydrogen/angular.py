from sage.all import (
    QQ,
    spherical_harmonic,
)

from .coordinates import (
    azimuth,
    polar_angle,
)
from .quantum_numbers import (
    check_angular_degree,
    check_axis_component,
)
from .symbolic import simplify_identity


def angular_mode(
    angular_degree,
    axis_component,
):
    check_angular_degree(angular_degree)
    check_axis_component(
        angular_degree,
        axis_component,
    )

    return spherical_harmonic(
        angular_degree,
        axis_component,
        polar_angle,
        azimuth,
    ).simplify_full()


def angular_conjugate(
    angular_degree,
    axis_component,
):
    return simplify_identity(
        QQ(-1) ** axis_component
        * angular_mode(
            angular_degree,
            -axis_component,
        )
    )
