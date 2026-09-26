SPDF_MAX_ANGULAR_DEGREE = 3


def angular_degrees_for_energy(
    energy_level,
    max_angular_degree=SPDF_MAX_ANGULAR_DEGREE,
):
    largest_angular_degree = min(
        energy_level - 1,
        max_angular_degree,
    )
    return range(largest_angular_degree + 1)


def axis_components_for_degree(angular_degree):
    return range(
        -angular_degree,
        angular_degree + 1,
    )


def unique_radial_modes(max_energy_level=4):
    return [
        (energy_level, angular_degree)
        for energy_level
        in range(1, max_energy_level + 1)
        for angular_degree
        in angular_degrees_for_energy(
            energy_level
        )
    ]


def angular_modes(max_angular_degree=3):
    return [
        (angular_degree, axis_component)
        for angular_degree
        in range(max_angular_degree + 1)
        for axis_component
        in axis_components_for_degree(
            angular_degree
        )
    ]


def spdf_states(max_energy_level=4):
    return [
        (
            energy_level,
            angular_degree,
            axis_component,
        )
        for energy_level, angular_degree
        in unique_radial_modes(max_energy_level)
        for axis_component
        in axis_components_for_degree(
            angular_degree
        )
    ]
