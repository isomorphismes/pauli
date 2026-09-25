# Evanescence

Repository: https://github.com/al2me6/evanescence

Web application: https://al2me6.github.io/evanescence

License: GNU AGPL v3

Evanescence is a from-the-ground-up implementation of hydrogenic orbitals intended for interactive visualization.

## Mathematics

Unlike implementations that hard-code a short list of orbitals, Evanescence evaluates the general equations for arbitrary supported parameters, subject to numerical limitations.

It supports:

- real hydrogen orbitals,
- complex hydrogen orbitals,
- linear combinations of real orbitals,
- molecular orbitals from Gaussian Cube data,
- nodal surfaces,
- wavefunction and probability-density cross-sections,
- radial plots,
- probability-density isosurfaces.

It deliberately uses `f32` rather than `f64` because visualization accuracy does not justify double precision throughout.

## Rendering

Its primary three-dimensional representation is a **Monte Carlo point cloud** sampled from the orbital probability distribution.

That is not Dauger's volume integration, but the general analytical orbital machinery is useful reference material for `laguerre`. In particular, it separates the problem of evaluating the quantum state from the problem of choosing a visual representation.
