# Dauger Research — Atom in a Box

Official page: https://daugerresearch.com/orbitals/mac.shtml

*Atom in a Box* is the direct reference for this repository. It displays hydrogenic atomic orbitals as three-dimensional clouds rather than only plotting spherical harmonics.

## Rendering

Dauger describes the renderer as **raytracing through the cloud**. Samples along each viewing ray are combined using **Simpson's-rule numerical integration**. The magnitude squared of the wavefunction controls brightness, and the app can also map the complex phase to color.

This is therefore a genuine volume-rendering approach rather than an isosurface or a collection of point particles.

Version 2 computes the eigenstates at run time, supports all 2109 eigenstates through `n = 18`, and supports superpositions of up to eight eigenstates.

## Pauli comparison after the checked-state renderer integration

Now implemented in the native viewer:

- checked hydrogen states drive the actual CPU volume renderer;
- explicit (n, ℓ, m, basis) values and documented real-basis transforms;
- bounded four-state selection, drag rotation and event-driven rendering;
- magnitude/phase amplitudes with density = magnitude²;
- GLES image presentation and a native-only APK.

Color currently projects phase to the existing two sign colors. Magnitude/phase
storage supports complex phase, but continuous phase coloring is not implemented.

Still future: a broader catalogue potentially toward n = 18, an arbitrary
state picker, continuous complex-phase coloring, superpositions, time
evolution, render-quality controls, and remaining Atom in a Box parity work.

## Source availability

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
