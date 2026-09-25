from sage.all import (
    QQ,
    diff,
    exp,
    factorial,
    gen_laguerre,
    infinity,
    integral,
    pi,
    sin,
    spherical_harmonic,
    sqrt,
    var,
)

radius, polar_angle, azimuth = var("radius polar_angle azimuth")


def check_state_numbers(energy_level, angular_degree, axis_component):
    if energy_level < 1:
        raise ValueError("energy_level must be at least 1")
    if angular_degree < 0 or angular_degree >= energy_level:
        raise ValueError(
            "angular_degree must satisfy 0 <= angular_degree < energy_level"
        )
    if abs(axis_component) > angular_degree:
        raise ValueError(
            "axis_component must satisfy abs(axis_component) <= angular_degree"
        )


def bound_state_energy(energy_level):
    if energy_level < 1:
        raise ValueError("energy_level must be at least 1")
    return -QQ(1) / (2 * energy_level**2)


def radial_mode(energy_level, angular_degree):
    check_state_numbers(energy_level, angular_degree, 0)

    scaled_radius = 2 * radius / energy_level
    normalization = sqrt(
        (QQ(2) / energy_level) ** 3
        * factorial(energy_level - angular_degree - 1)
        / (
            2
            * energy_level
            * factorial(energy_level + angular_degree)
        )
    )

    return (
        normalization
        * exp(-radius / energy_level)
        * scaled_radius**angular_degree
        * gen_laguerre(
            energy_level - angular_degree - 1,
            2 * angular_degree + 1,
            scaled_radius,
        )
    ).simplify_full()


def angular_mode(angular_degree, axis_component):
    if angular_degree < 0:
        raise ValueError("angular_degree must be nonnegative")
    if abs(axis_component) > angular_degree:
        raise ValueError(
            "axis_component must satisfy abs(axis_component) <= angular_degree"
        )

    return spherical_harmonic(
        angular_degree,
        axis_component,
        polar_angle,
        azimuth,
    ).simplify_full()


def bound_state(energy_level, angular_degree, axis_component):
    check_state_numbers(energy_level, angular_degree, axis_component)
    return (
        radial_mode(energy_level, angular_degree)
        * angular_mode(angular_degree, axis_component)
    ).simplify_full()


def simplify_identity(expression):
    return expression.simplify_full().simplify_trig().simplify_full()


def radial_equation_residual(energy_level, angular_degree):
    radial = radial_mode(energy_level, angular_degree)
    energy = bound_state_energy(energy_level)

    radial_laplacian = (
        diff(radial, radius, 2)
        + 2 / radius * diff(radial, radius)
        - angular_degree * (angular_degree + 1) / radius**2 * radial
    )

    return simplify_identity(
        -QQ(1) / 2 * radial_laplacian
        - radial / radius
        - energy * radial
    )


def angular_equation_residual(angular_degree, axis_component):
    angular = angular_mode(angular_degree, axis_component)

    sphere_laplacian = (
        diff(
            sin(polar_angle) * diff(angular, polar_angle),
            polar_angle,
        )
        / sin(polar_angle)
        + diff(angular, azimuth, 2) / sin(polar_angle) ** 2
    )

    return simplify_identity(
        sphere_laplacian
        + angular_degree * (angular_degree + 1) * angular
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

    sphere_laplacian = (
        diff(
            sin(polar_angle) * diff(state, polar_angle),
            polar_angle,
        )
        / sin(polar_angle)
        + diff(state, azimuth, 2) / sin(polar_angle) ** 2
    )

    spatial_laplacian = (
        diff(state, radius, 2)
        + 2 / radius * diff(state, radius)
        + sphere_laplacian / radius**2
    )

    return simplify_identity(
        -QQ(1) / 2 * spatial_laplacian
        - state / radius
        - energy * state
    )


def radial_inner_product(
    first_energy_level,
    second_energy_level,
    angular_degree,
):
    first = radial_mode(first_energy_level, angular_degree)
    second = radial_mode(second_energy_level, angular_degree)

    return simplify_identity(
        integral(
            first * second * radius**2,
            radius,
            0,
            infinity,
        )
    )


def angular_conjugate(angular_degree, axis_component):
    return simplify_identity(
        QQ(-1) ** axis_component
        * angular_mode(
            angular_degree,
            -axis_component,
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


def unique_radial_modes(max_energy_level=4):
    return [
        (energy_level, angular_degree)
        for energy_level in range(1, max_energy_level + 1)
        for angular_degree in range(
            min(energy_level - 1, 3) + 1
        )
    ]


def angular_modes(max_angular_degree=3):
    return [
        (angular_degree, axis_component)
        for angular_degree in range(max_angular_degree + 1)
        for axis_component in range(
            -angular_degree,
            angular_degree + 1,
        )
    ]


def spdf_states(max_energy_level=4):
    states = []

    for energy_level in range(1, max_energy_level + 1):
        largest_angular_degree = min(
            energy_level - 1,
            3,
        )

        for angular_degree in range(
            largest_angular_degree + 1
        ):
            for axis_component in range(
                -angular_degree,
                angular_degree + 1,
            ):
                states.append(
                    (
                        energy_level,
                        angular_degree,
                        axis_component,
                    )
                )

    return states
