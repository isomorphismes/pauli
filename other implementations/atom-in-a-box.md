# Dauger Research — Atom in a Box

Official page: https://daugerresearch.com/orbitals/mac.shtml

*Atom in a Box* is the direct reference for this repository. It displays hydrogenic atomic orbitals as three-dimensional clouds rather than only plotting spherical harmonics.

## Rendering

Dauger describes the renderer as **raytracing through the cloud**. Samples along each viewing ray are combined using **Simpson's-rule numerical integration**. The magnitude squared of the wavefunction controls brightness, and the app can also map the complex phase to color.

This is therefore a genuine volume-rendering approach rather than an isosurface or a collection of point particles.

Version 2 computes the eigenstates at run time, supports all 2109 eigenstates through `n = 18`, and supports superpositions of up to eight eigenstates.

## Source status

No public source release was located in the September 2026 search. Older releases were distributed as shareware applications; version 2 was rewritten in SwiftUI and is commercially distributed.

The official documentation does, however, describe enough of the rendering algorithm to make an independent implementation possible.

## Relevance to laguerre

This is the behavior to reproduce rather than the code to copy:

1. evaluate the hydrogenic wavefunction,
2. trace a ray through three-dimensional space,
3. sample the wavefunction along that ray,
4. integrate the samples,
5. turn probability density and optionally phase into the pixel value.

The ray tracer should remain a replaceable dependency. Once the shared ray tracer planned for the SURFER work has a stable home, `laguerre` should pin that implementation rather than growing an unrelated renderer.
