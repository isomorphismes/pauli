# Ray tracer

The ray tracer now has a complete first executable implementation in current
Idriç, alongside the type sketch that established its semantic boundaries.

## What runs

`RayTracer.idric` renders a 64 × 48 PPM image to standard output.  The first
scene is a shaded sphere, but the intersection path is **not** hard-wired to a
sphere or to algebraic polynomials.

The executable path is:

```text
pixel
  → view sample
  → same-parameter camera/clipping/surface ray bundle
  → unit-sphere clipping interval
  → representation-specific surface intersection
  → first hit parameter
  → surface point
  → surface differential
  → camera-space normal
  → front/back material
  → ambient + diffuse + specular lighting
  → RGB
  → PPM pixel
```

The current CI pins an exact Idriç compiler revision, typechecks the executable,
runs `main`, verifies the PPM dimensions and pixel count, checks that the frame
contains multiple distinct colors, and retains the rendered frame as an
artifact.

## Why the core surface is generic

**Algorithmic reference: Christian Stussak's original
[`jsurf` ray tracer](https://github.com/IMAGINARY/jsurf)**, written for
[IMAGINARY's SURFER](https://www.imaginary.org/program/surfer) at the
Mathematisches Forschungsinstitut Oberwolfach. His implementation is the
specific reference for the distinction between camera/clipping/surface
coordinates, ray parameter preservation, and prepared algebraic derivatives.
These are not being presented as original inventions of Pauli. Several of
Stussak's design concepts remain explicit here:

- camera space, clipping space, and surface space are different;
- their rays share one parameter;
- clipping happens in clipping space;
- intersection happens in surface space;
- the surface differential is evaluated before producing a camera-space normal;
- intersection, shading, and image generation remain separate stages.

But Pauli should not define every renderable surface as a polynomial.

The existing hydrogen scaffold contains exponentials, Laguerre functions,
spherical harmonics, and complex-valued states.  A visualization can derive a
real field from a state and render one of that field's level sets.  The core
therefore takes a `SurfaceIntersector` and a
`SurfaceDifferentialEvaluator` for whatever surface representation the scene
uses.

Two representations are currently described in `RayTracerTypes.idric`:

- `LevelSetSurface`: a real field, its differential, and the level to render;
- `PreparedAlgebraicSurface`: the Stussak-inspired sparse-polynomial handoff
  with the surface and its three prepared partial derivatives.

The runnable implementation currently uses `LevelSetSurface Double`.  It
samples the clipped ray in 128 ordered segments and bisects the first sign
change for 28 steps. This is **independent Idriç code informed by SURFER's
architecture**, not a copy of Stussak's `jsurf` implementation or an
equivalent translation of his Descartes root finder: a pure tangency or a
sufficiently narrow pair of crossings can be missed.

Unlike the [Algebraic Variety Explorer Android port](https://github.com/isomorphismes/algebraic-variety-explorer-mobile),
which includes Stussak's **actual** original Java `jsurf` code, Pauli uses
this implementation only as an explicit algorithmic reference.

## Numerical representation

The public type sketch remains representation-parametric.

The first executable specializes geometry and color to `Double` because that
is the floating primitive exposed by today's inherited Idris 2 runtime.  This
is an implementation fact of the experiment, not a decision that future Idriç
ray tracing should standardize on binary64.

## Still intentionally absent

The first running renderer does not yet include:

- orbital-state → real-field selection;
- the SURFER algebraic specialization/root-finder implementation;
- rotated or perspective cameras;
- antialiasing;
- concurrency or cancellation;
- a packed pixel-buffer backend;
- Android presentation.

Those are additions to a running tracer now, rather than prerequisites for
proving that the pipeline can be expressed and executed in Idriç.
