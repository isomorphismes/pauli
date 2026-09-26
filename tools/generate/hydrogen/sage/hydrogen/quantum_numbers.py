def check_energy_level(energy_level):
    if energy_level < 1:
        raise ValueError(
            "energy_level must be at least 1"
        )


def check_angular_degree(angular_degree):
    if angular_degree < 0:
        raise ValueError(
            "angular_degree must be nonnegative"
        )


def check_axis_component(
    angular_degree,
    axis_component,
):
    if abs(axis_component) > angular_degree:
        raise ValueError(
            "axis_component must satisfy "
            "abs(axis_component) <= angular_degree"
        )


def check_radial_numbers(
    energy_level,
    angular_degree,
):
    check_energy_level(energy_level)
    check_angular_degree(angular_degree)

    if angular_degree >= energy_level:
        raise ValueError(
            "angular_degree must satisfy "
            "0 <= angular_degree < energy_level"
        )


def check_state_numbers(
    energy_level,
    angular_degree,
    axis_component,
):
    check_radial_numbers(
        energy_level,
        angular_degree,
    )
    check_axis_component(
        angular_degree,
        axis_component,
    )
