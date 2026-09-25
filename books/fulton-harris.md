# William Fulton and Joe Harris — *Representation Theory: A First Course*

Related repository: https://github.com/walnut-burgundy/fulton

The `Fulton` repository is the place for general representation theory. This note records why representation theory is physically central to `pauli`.

## What a representation means here

A physical symmetry acts on a space of possible states or quantities.

A **representation** is that action when the space is linear. The representation is the action itself. A matrix is only what the action looks like after a basis has been chosen.

For hydrogen, rotations act on angular wavefunctions. Therefore the space of functions on the sphere carries a representation of the rotation group.

The useful question is not:

> what integers are allowed for a quantum number?

It is:

> how does this space break into pieces that rotations cannot further decompose?

Those pieces are **irreducible representations**.

A spherical-harmonic space of fixed angular degree is one irreducible rotation type. Choosing an axis and then a basis adapted to that axis produces the familiar integer labels. Those labels are bookkeeping attached to the representation, not the conceptual starting point.

For ordinary orbital angular dependence the relevant group is `SO(3)`. Spin brings in its double cover `SU(2)`, which is related but should be treated separately.

## Why Fulton and Harris belongs here

Fulton and Harris is useful precisely because it is not a quantum-mechanics text. It lets the representation-theoretic structure stand on its own:

- a group acts;
- invariant subspaces may exist;
- irreducible representations are the elementary symmetry types;
- a complicated representation can often be understood by decomposing it into those pieces.

In `pauli`, that language explains why spherical harmonics are natural before any associated Legendre formula is written down.

Use the `Fulton` repository for the general theory. Use `pauli` for rotations, spherical harmonics, the Coulomb problem, and physical state spaces.
