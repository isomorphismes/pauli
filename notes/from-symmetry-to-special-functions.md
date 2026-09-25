# From geometry to the special functions

The symbolic notebook should not start by asking Sage for named polynomial families.

It should make those families appear as the answer to a sequence of geometric and boundary-value questions.

## 1. The point source fixes the radial geometry

A point source in three-dimensional space has spherical level sets.

Conserved flux through those spheres gives the inverse-square field and therefore the inverse-distance Coulomb potential.

See [Coulomb geometry before the formula](coulomb-geometry.md).

This is the physical input to the hydrogen problem.

## 2. Geometry gives the differential operator

For an ordinary scalar function `f` on Euclidean three-space, the Laplacian can be built from the exterior derivative and the Hodge star:

```text
Delta f = * d * d f.
```

After spherical coordinates are chosen, the Euclidean metric is

```text
ds^2 = dr^2 + r^2(d theta^2 + sin^2(theta) d phi^2).
```

The Laplacian then separates into

```text
radial part + (1 / r^2) × sphere part.
```

This split is not a trick invented to solve hydrogen. It reflects the geometry of a radial problem.

## 3. Rotations organize the angular part before coordinates do

The sphere part is unchanged by rotations.

Therefore rotations act on each of its eigenspaces.

The first question is:

> how do those eigenspaces decompose under rotations?

The finite-dimensional irreducible pieces are the spherical-harmonic spaces.

At this stage there is a rotation representation and an eigenspace, but no preferred axis and no need for associated Legendre formulas.

See [Spherical harmonics before Legendre formulas](spherical-harmonics.md).

## 4. Choosing an axis produces the familiar angular equation

Only after an axis and spherical coordinates are chosen do we split the angular dependence again.

Rotation about the chosen axis gives the periodic angular factor.

The remaining polar equation is the associated Legendre equation.

Regularity at the poles selects the allowed solutions.

So the notebook should derive the associated Legendre problem from the sphere operator and then verify that Sage's named special function is the same solution.

The named function is a cross-check and convenient representation, not the starting assumption.

## 5. Bound and scattering states are different physical questions

The Coulomb problem allows more than one kind of state.

A bound state describes an electron belonging to the atom rather than an incoming or outgoing scattering state. It is not confined inside a hard wall: its probability density can extend arbitrarily far from the nucleus. What distinguishes the bound stationary states is that they are normalizable and lie in the discrete spectrum below the escape threshold.

Once that physical question is fixed, the radial equation has consequences at both ends of the half-line.

Near the nucleus the acceptable solution cannot have the singular behavior of the rejected branch.

Far from the nucleus, a negative-energy bound solution has a decaying exponential rather than the oscillatory behavior of a scattering state.

Before introducing a named polynomial, factor out the behavior already forced by those two limits:

```text
regular power near the origin
×
decaying exponential at infinity
×
remaining function.
```

After a dimensionless radius is introduced, the remaining function satisfies the associated Laguerre equation.

Normalizability then rules out the growing branch. The surviving series terminates, leaving a polynomial and restricting the allowed bound-state energies.

Again, the notebook should derive the recurrence and termination condition first, then identify the result with Sage's generalized Laguerre polynomial.

## 6. The exact notebook should prove its own changes of form

For every family through `s`, `p`, `d`, and `f`, the symbolic work should check:

1. the geometric operator was transformed correctly;
2. the angular equation follows from the sphere operator after the coordinate choice;
3. the radial equation follows from the Coulomb problem;
4. the endpoint factors leave the claimed polynomial equation;
5. the series recurrence terminates at the claimed degree;
6. the derived polynomial matches the library special function up to the stated normalization and phase convention;
7. the resulting complete state satisfies the original stationary equation;
8. normalization and orthogonality hold.

This is stronger than asking a computer algebra system to print a familiar formula.

## 7. Symmetry should make predictions before the calculation

Stephanie Frank Singer's order is the governing one.

Before solving the coordinate equations, the notebook should already know what rotation symmetry predicts:

- the angular state spaces come in irreducible families;
- each family has a definite finite dimension;
- choosing an axis selects a basis inside that family;
- changing basis does not create a new physical space.

The coordinate calculation then realizes a structure that was already predicted.

The special functions are not the explanation.
They are the coordinate answer.
