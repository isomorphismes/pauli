# Second-order equations and natural modes

Second order does **not** by itself mean oscillation.

What second order tells us is that the equation is sensitive to curvature, acceleration, or change of slope rather than only to the value of a quantity or its first-rate change.

The simplest harmonic example is a restoring law:

```text
acceleration = - constant × displacement
```

The minus sign matters. It makes displacement generate acceleration back toward equilibrium, and the resulting motion oscillates.

Change the sign and the same second-order structure produces exponential growth and decay instead.

## Why modes keep appearing

Second-order spatial operators with boundary conditions naturally lead to questions of the form:

> which shapes reproduce themselves up to scale when the operator acts on them?

Those shapes are eigenmodes.

For a vibrating string they are normal modes.  
For the sphere they are spherical harmonics.  
For Sturm–Liouville problems they are the orthogonal eigenfunctions selected by the operator and boundary conditions.

So harmonic decomposition is not a trick invented because sines and cosines are pleasant to calculate with. It is a general response to linear operators whose eigenmodes organize the possible behavior.

## House rule

When a harmonic family appears, explain:

1. what second-order operator is acting;
2. what domain and boundary conditions define the problem;
3. what symmetry is present;
4. why the eigenmodes form the natural decomposition.

Only then write the familiar trigonometric, Legendre, Laguerre, or other special-function formula.
