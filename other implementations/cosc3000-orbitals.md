# COSC3000 Hydrogen Orbital Visualiser

Repository: https://github.com/ManavSachdeva817/cosc-3000-orbitals

Live application: https://cosc-3000-orbitals.vercel.app/

No license was present in the repository when checked in September 2026, so treat its source as reference material unless that changes.

## Rendering

This implementation is especially relevant because it contains an explicit GPU volume renderer.

It evaluates the wavefunction onto a `64 × 64 × 64` `Float32` grid, uploads that grid as a Three.js 3-D texture, and ray-marches through the texture in GLSL. The current shader uses 100 samples along each ray and front-to-back alpha compositing.

The project also supplies two other views of the same orbital:

- marching-cubes isosurfaces,
- Monte Carlo point clouds.

Positive and negative wavefunction values are given different colors.

## Comparison with Atom in a Box

The ray marching is close in spirit to Dauger's renderer: both accumulate contributions along a viewing ray through a three-dimensional probability cloud.

The important difference is the intermediate grid. COSC3000 precomputes a sampled 3-D volume and interpolates it during rendering. Atom in a Box is described in terms of evaluating and integrating the cloud along the ray.

For `laguerre`, an interesting experiment is therefore to retain the GPU ray-marching structure but evaluate the analytical wavefunction at the ray samples, avoiding the `64³` intermediate volume entirely.
