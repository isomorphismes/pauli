# hortont424/orbitals

Repository: https://github.com/hortont424/orbitals

License: two-clause BSD-style license

This is an older hydrogen-orbital renderer built around Python and OpenCL. The repository contains a Python driver (`hydrogen.py`) and an OpenCL kernel (`hydrogen.cl`), along with a Mathematica notebook used around the same work.

## Rendering and computation

Its main relevance is the decision to move evaluation of the hydrogen orbital over many spatial points onto OpenCL. It predates today's convenient GPU shader and compute frameworks, but it exposes the same basic opportunity: evaluation of the wavefunction at independent spatial samples is highly parallel.

## Relevance to laguerre

This is useful evidence for keeping the mathematical evaluator independent of the rendering API. The same evaluator can conceptually feed:

- CPU numerical integration,
- a graphics shader,
- an OpenCL-style compute kernel,
- or another shared raytracer backend.

The implementation is old, but small enough to be useful when comparing how much machinery is actually required to move orbital evaluation onto a GPU.
