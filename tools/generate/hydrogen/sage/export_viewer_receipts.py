"""Build-time real-basis identities and independent Cartesian receipts."""
from math import acos, atan2, hypot

import sympy as sp
from sage.all import CDF, I, sqrt
from hydrogen_states import bound_state, radius, polar_angle, azimuth

sample_points = [
    (0, 0, 0), (1, 0, 0), (0, 1, 0), (0, 0, 1),
    (1, 2, 3), (-1, 2, 3), (1, -2, 3), (1, 2, -3),
    (4, -3, 2), (-7, -5, -2),
]

r, theta, phi = sp.symbols("r theta phi", real=True)
x = r * sp.sin(theta) * sp.cos(phi)
y = r * sp.sin(theta) * sp.sin(phi)
z = r * sp.cos(theta)
cartesian = [
    sp.exp(-r) / sp.sqrt(sp.pi),
    x * sp.exp(-r / 2) / sp.sqrt(32 * sp.pi),
    2 * x * y * sp.exp(-r / 3) / (81 * sp.sqrt(2 * sp.pi)),
    sp.sqrt(3) * x * y * z * sp.exp(-r / 4) / (1536 * sp.sqrt(sp.pi)),
]

def independent_state(n, degree, component):
    normalization = sp.sqrt(
        sp.Rational(2, n)**3 * sp.factorial(n-degree-1)
        / (2*n*sp.factorial(n+degree))
    )
    radial = normalization * sp.exp(-r/n) * (2*r/n)**degree * sp.assoc_laguerre(
        n-degree-1, 2*degree+1, 2*r/n
    )
    return radial * sp.expand_func(sp.Ynm(degree, component, theta, phi))

states = [(1, 0, 0, 0), (2, 1, 1, 1), (3, 2, 2, 2), (4, 3, 2, 2)]
for index, (n, degree, component, basis) in enumerate(states):
    positive = independent_state(n, degree, component)
    negative = independent_state(n, degree, -component)
    if basis == 0:
        independent = positive
    elif basis == 1:
        independent = (negative + (-1)**component * positive) / sp.sqrt(2)
    else:
        independent = sp.I * (negative - (-1)**component * positive) / sp.sqrt(2)
    residual = sp.simplify(sp.trigsimp(sp.expand_complex(independent - cartesian[index])))
    if residual != 0:
        raise AssertionError(f"real-basis identity failed: {n, degree, component, basis}: {residual}")

    sage_positive = bound_state(n, degree, component)
    sage_negative = bound_state(n, degree, -component)
    # Equal-magnitude orthonormal coefficients preserve unit normalization.
    if basis == 0:
        sage_state = sage_positive
    elif basis == 1:
        sage_state = (sage_negative + (-1)**component * sage_positive) / sqrt(2)
    else:
        sage_state = (sage_negative - (-1)**component * sage_positive) * I / sqrt(2)
    for point in sample_points:
        sample_radius = hypot(hypot(point[0], point[1]), point[2])
        sample_theta = acos(point[2]/sample_radius) if sample_radius else 0.0
        sample_phi = atan2(point[1], point[0])
        expected = complex(cartesian[index].subs({r: sample_radius, theta: sample_theta, phi: sample_phi}).evalf(30))
        # Sage's symbolic coordinates declare positive radius; use the
        # analytic Cartesian limit at the origin, not a singular substitution.
        if sample_radius:
            checked = complex(CDF(sage_state.subs({
                radius: sample_radius, polar_angle: sample_theta, azimuth: sample_phi
            })))
            if abs(checked-expected) > 2e-13:
                raise AssertionError(f"Sage/SymPy viewer mismatch: {index}, {point}")
        print(index, *point, format(abs(expected), ".17g"),
              format(atan2(expected.imag, expected.real), ".17g"), sep="\t")
