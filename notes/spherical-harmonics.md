# Spherical harmonics before Legendre formulas

Do not begin with associated Legendre polynomials.

Begin with the sphere, the action of rotations on functions on the sphere, and the rotation-invariant Laplacian.

The question is:

> how does the space of functions on the sphere decompose under rotations?

The answer is into finite-dimensional irreducible rotation representations. Each such piece is also an eigenspace of the spherical Laplacian.

That finite-dimensional space is the primary object.

Only after choosing a particular rotation axis do we choose a basis adapted to rotations about that axis. The familiar magnetic-number labels describe basis vectors inside one irreducible representation. The range from negative angular-momentum number through positive angular-momentum number is therefore not a rule to memorize; it is the weight structure of that representation.

Only after choosing spherical coordinates do the basis functions acquire their familiar coordinate form involving associated Legendre polynomials and an azimuthal complex phase.

So the explanatory order is:

1. rotation action;
2. irreducible representation;
3. spherical-harmonic space;
4. choice of axis and basis;
5. coordinate expression;
6. associated Legendre polynomial.

General representation theory belongs in the existing `Fulton` repository. This repository should specialize that theory to the rotation action needed for the hydrogen problem rather than redeveloping it.
