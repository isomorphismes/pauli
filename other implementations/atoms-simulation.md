# Atoms-Simulation

Repository: https://github.com/toxicbishop/Atoms-Simulation

License: MIT

A C++/OpenGL hydrogen-orbital visualizer with 2-D, real-time 3-D, and raytraced versions.

## Rendering

The implementation samples the orbital probability distribution into particles. Its raytracer sends those sampled particles to the GPU as small spheres and raytraces the spheres.

That makes it useful raytracing reference code, but it is **not the same renderer as Atom in a Box**. Dauger integrates a continuous cloud along each viewing ray; this project first reduces the distribution to discrete particles.

## Useful pieces

- compact C++/OpenGL implementation,
- analytical hydrogen-orbital machinery,
- interactive camera,
- GPU raytracing structure,
- permissive MIT license.

For `laguerre`, the main value is architectural and implementation reference material for the renderer boundary. The particle representation itself should not silently replace the continuous volume integral that defines the Atom-in-a-Box-style image.
