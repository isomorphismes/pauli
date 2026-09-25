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
- the surface equation is solved in surface space;
- a surface gradient is a covector;
- a normal used for shading lives in camera space;
- a prepared algebraic surface contains the surface polynomial and its three
  partial derivatives;
- first-root selection is a separate stage from polynomial specialization.

The root-method vocabulary is property-first.  The
`sign_variation_subdivision` choice is the slot corresponding to the family of
ideas used by Stussak's `DescartesRootFinder`; the eponym is not being used as
the explanation.

## First Idriç pipeline

The current types make room for the following composition without implementing
it yet:

```text
view sample
  → same-parameter ray bundle
  → clipping interval
  → surface polynomial on the ray
  → first root
  → surface point
  → surface differential
  → camera-space normal
  → material and light shading
  → trace result
```

`RayTracerTypes.idric` also uses current Idriç `choice ... one_of` syntax
for the closed coordinate-space and root-method alternatives.

## Deliberately unsettled

This branch does **not** yet choose:

- F16 versus F32 geometry;
- a concrete polynomial storage ABI;
- a matrix/quaternion/other representation for coordinate maps;
- a particular first-root implementation;
- antialiasing;
- concurrency;
- a pixel-buffer format;
- a connection to the open symbolic hydrogen scaffold.

Those should follow only after the type boundaries are worth keeping.
