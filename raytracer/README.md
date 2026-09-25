# Ray tracer

This directory starts with the type system, not the rendering loop.

The first sketch is in current Idriç and is deliberately small enough to revise
before numerical choices harden into architecture.

## Conceptual starting point

Christian Stussak's jsurf/SURFER renderer is a major reference point, including
work associated with the Mathematisches Forschungsinstitut Oberwolfach.

This is not intended to be a line-by-line port.  The first pass keeps concepts
that remain useful on their own:

- camera space, clipping space, and surface space are different;
- the corresponding rays share one parameter;
- clipping happens in clipping space;
- a surface intersection is solved in surface space;
- the differential of a scalar field is a covector;
- a normal used for shading lives in camera space;
- first-intersection logic is a separate stage from camera generation,
  clipping, differential evaluation, and shading.

## What the Idriç pass changed

The first draft made the useful mistake of treating every renderable surface as
a sparse polynomial.  That is appropriate for SURFER, but not for Pauli.

Hydrogen states contain exponentials, Laguerre functions, spherical harmonics,
and complex values.  A visualization may derive a real field such as a density
and render one of its level sets.  The core ray tracer therefore now accepts an
arbitrary surface representation together with a matching
`SurfaceIntersector`.

Two surface families are sketched separately:

- `LevelSetSurface`: a real field, its differential, and the level to render;
- `PreparedAlgebraicSurface`: the Stussak-inspired sparse-polynomial handoff
  with the surface and its three prepared partial derivatives.

The algebraic family has its own specialization and first-root types.  It is no
longer the definition of a ray-traceable surface.

## First Idriç pipeline

The current types make room for the following composition without implementing
it yet:

```text
view sample
  → same-parameter ray bundle
  → clipping interval
  → representation-specific surface intersector
  → first hit parameter
  → surface point
  → surface differential
  → camera-space normal
  → material and light shading
  → trace result
```

`RayTracerTypes.idric` uses current Idriç `choice ... one_of` syntax for
the closed coordinate-space and algebraic root-method alternatives.

The numerical representation is left as a type parameter.  This lets the
semantic boundaries settle before choosing an F16/F32 policy for the actual
renderer.

## Deliberately unsettled

This branch does **not** yet choose:

- F16 versus F32 geometry or color;
- how a complex hydrogen state becomes the real field to visualize;
- the concrete representation of coordinate and normal maps;
- the level-set intersection algorithm;
- the exact algebraic polynomial storage ABI;
- antialiasing;
- concurrency;
- a pixel-buffer format;
- a connection to the open symbolic hydrogen scaffold.

Those should follow only after the type boundaries are worth keeping.
