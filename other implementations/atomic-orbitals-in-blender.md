# Atomic-Orbitals-in-Blender

Repository: https://github.com/dom128/Atomic-Orbitals-in-Blender

License: GNU GPL v3

This project uses Blender's rendering system to display hydrogen-like atomic wavefunctions and probability-density distributions in three-dimensional space.

## Rendering

The useful idea here is to hand the orbital field to an existing general raytracing system rather than implementing the complete renderer inside the orbital program.

It can render both the wavefunction itself and

```text
ρ(x) = |ψ(x)|²
```

as three-dimensional fields.

## Relevance to laguerre

This is less useful as a real-time implementation than the GPU ray-marching projects, but it is a clean example of the desired separation:

- the orbital code defines the field,
- the raytracer determines how that field is viewed.

That is the same separation `laguerre` should preserve when it pins the shared raytracer used elsewhere rather than embedding a project-specific raytracer.
