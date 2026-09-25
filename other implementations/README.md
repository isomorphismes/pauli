# Other implementations

Notes on existing hydrogen-orbital visualization implementations and related work.

These are references for `laguerre`, a reimplementation of Dauger Research's *Atom in a Box*. The useful comparison is not just which equations each project evaluates, but how each one represents and renders the three-dimensional wavefunction.

## Implementations

- [Dauger Research — Atom in a Box](atom-in-a-box.md)
- [Atoms-Simulation](atoms-simulation.md)
- [COSC3000 Hydrogen Orbital Visualiser](cosc3000-orbitals.md)
- [Evanescence](evanescence.md)
- [Atomic-Orbitals-in-Blender](atomic-orbitals-in-blender.md)
- [hortont424/orbitals](pyopencl-orbitals.md)

## Common mathematical core

For the hydrogen atom,

```text
ψ_nlm(r, θ, φ) = R_nl(r) Y_l^m(θ, φ)
```

The radial solution uses associated Laguerre polynomials. The angular solution uses associated Legendre polynomials together with the azimuthal phase, conventionally packaged as spherical harmonics.

The implementations mainly differ in what they do after evaluating the wavefunction: direct volume integration, GPU ray marching, Monte Carlo point clouds, isosurfaces, or particle rendering.
