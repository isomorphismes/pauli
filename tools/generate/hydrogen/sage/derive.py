from sage.all import (
    QQ,
    PolynomialRing,
    diff,
    exp,
    gen_laguerre,
    matrix,
    var,
)

space = PolynomialRing(QQ, names=("x", "y", "z"))
x, y, z = space.gens()
radius = var("radius")


def homogeneous_monomials(degree):
    result = []

    for x_power in range(degree + 1):
        for y_power in range(
            degree - x_power + 1
        ):
            z_power = (
                degree
                - x_power
                - y_power
            )
            result.append(
                x**x_power
                * y**y_power
                * z**z_power
            )

    return result


def local_balance(poly):
    return (
        poly.derivative(x).derivative(x)
        + poly.derivative(y).derivative(y)
        + poly.derivative(z).derivative(z)
    )


def harmonic_basis(degree):
    domain = homogeneous_monomials(degree)

    if degree < 2:
        return domain

    codomain = homogeneous_monomials(
        degree - 2
    )

    operator = matrix(
        QQ,
        [
            [
                local_balance(source)
                .monomial_coefficient(target)
                for source in domain
            ]
            for target in codomain
        ],
    )

    kernel = operator.right_kernel()

    return [
        sum(
            coefficient * domain[index]
            for index, coefficient
            in enumerate(kernel_vector)
        )
        for kernel_vector
        in kernel.basis()
    ]


def angular_dimensions(
    largest_degree=3,
):
    return [
        (
            degree,
            len(harmonic_basis(degree)),
        )
        for degree
        in range(largest_degree + 1)
    ]


def radial_coefficients(
    energy_family,
    angular_degree,
):
    polynomial_degree = (
        energy_family
        - angular_degree
        - 1
    )

    if polynomial_degree < 0:
        raise ValueError(
            "angular degree must be smaller "
            "than the bound-energy family"
        )

    inverse_length = (
        QQ(1) / energy_family
    )

    coefficients = [QQ(1)]

    for power in range(polynomial_degree):
        numerator = (
            2
            * (
                inverse_length
                * (
                    power
                    + angular_degree
                    + 1
                )
                - 1
            )
        )

        denominator = (
            (power + 1)
            * (
                power
                + 2 * angular_degree
                + 2
            )
        )

        coefficients.append(
            (
                numerator
                / denominator
            )
            * coefficients[-1]
        )

    termination = (
        inverse_length
        * (
            polynomial_degree
            + angular_degree
            + 1
        )
        - 1
    )

    if termination != 0:
        raise AssertionError(
            "radial recurrence did not terminate"
        )

    return coefficients


def radial_polynomial(
    energy_family,
    angular_degree,
):
    return sum(
        coefficient
        * radius**power
        for power, coefficient
        in enumerate(
            radial_coefficients(
                energy_family,
                angular_degree,
            )
        )
    )


def radial_shape(
    energy_family,
    angular_degree,
):
    return (
        radius**angular_degree
        * exp(
            -radius / energy_family
        )
        * radial_polynomial(
            energy_family,
            angular_degree,
        )
    )


def radial_energy(
    energy_family,
):
    return (
        -QQ(1)
        / (
            2
            * energy_family**2
        )
    )


def radial_equation_residual(
    energy_family,
    angular_degree,
):
    shape = radial_shape(
        energy_family,
        angular_degree,
    )

    return (
        diff(shape, radius, 2)
        + 2 / radius
        * diff(shape, radius)
        + (
            2
            * radial_energy(
                energy_family
            )
            + 2 / radius
            - (
                angular_degree
                * (
                    angular_degree + 1
                )
                / radius**2
            )
        )
        * shape
    ).simplify_full()


def library_radial_polynomial(
    energy_family,
    angular_degree,
):
    polynomial_degree = (
        energy_family
        - angular_degree
        - 1
    )

    return gen_laguerre(
        polynomial_degree,
        2 * angular_degree + 1,
        2 * radius / energy_family,
    )


def radial_rows(
    largest_energy_family=4,
):
    return [
        (
            energy_family,
            angular_degree,
            radial_coefficients(
                energy_family,
                angular_degree,
            ),
        )
        for energy_family
        in range(
            1,
            largest_energy_family + 1,
        )
        for angular_degree
        in range(energy_family)
    ]


def state_counts(
    largest_energy_family=4,
):
    return [
        sum(
            2 * degree + 1
            for degree
            in range(energy_family)
        )
        for energy_family
        in range(
            1,
            largest_energy_family + 1,
        )
    ]


def verify():
    for degree, dimension in angular_dimensions():
        basis = harmonic_basis(degree)

        if any(
            local_balance(poly) != 0
            for poly in basis
        ):
            raise AssertionError(
                f"degree {degree} basis "
                "is not locally balanced"
            )

        expected = 2 * degree + 1

        if dimension != expected:
            raise AssertionError(
                f"degree {degree}: "
                f"expected {expected}, "
                f"got {dimension}"
            )

    for (
        energy_family,
        angular_degree,
        _,
    ) in radial_rows():
        residual = (
            radial_equation_residual(
                energy_family,
                angular_degree,
            )
        )

        if residual != 0:
            raise AssertionError(
                "derived radial shape failed "
                f"for {energy_family=}, "
                f"{angular_degree=}: "
                f"{residual}"
            )

        named = library_radial_polynomial(
            energy_family,
            angular_degree,
        )

        derived = radial_polynomial(
            energy_family,
            angular_degree,
        )

        ratio = (
            named / derived
        ).simplify_full()

        if diff(
            ratio,
            radius,
        ).simplify_full() != 0:
            raise AssertionError(
                "derived polynomial differs from "
                "Sage's named family by more "
                "than an overall scale"
            )

    counts = state_counts()

    if counts != [1, 4, 9, 16]:
        raise AssertionError(
            f"unexpected state counts: {counts}"
        )

    if sum(counts) != 30:
        raise AssertionError(
            "expected 30 spatial states "
            "through the fourth family"
        )

    return True
