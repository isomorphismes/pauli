load("symbolic/hydrogen_states.sage")


def require_zero(name, expression):
    reduced = simplify_identity(expression)
    if reduced != 0:
        raise AssertionError(f"{name} did not reduce to zero: {reduced}")


states = spdf_states()

if len(states) != 30:
    raise AssertionError(f"expected 30 spatial states through s, p, d, f; got {len(states)}")

for energy_level, angular_degree, axis_component in states:
    require_zero(
        (
            "radial equation "
            f"energy_level={energy_level} "
            f"angular_degree={angular_degree}"
        ),
        radial_equation_residual(
            energy_level,
            angular_degree,
        ),
    )

    require_zero(
        (
            "sphere equation "
            f"angular_degree={angular_degree} "
            f"axis_component={axis_component}"
        ),
        angular_equation_residual(
            angular_degree,
            axis_component,
        ),
    )

    require_zero(
        (
            "stationary hydrogen equation "
            f"energy_level={energy_level} "
            f"angular_degree={angular_degree} "
            f"axis_component={axis_component}"
        ),
        stationary_equation_residual(
            energy_level,
            angular_degree,
            axis_component,
        ),
    )

print(f"PASS: {len(states)} exact Sage states through s, p, d, f")
