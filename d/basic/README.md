# Basic Pauli in D

This is a direct D translation of the retained basic Pauli orbital viewer.

## Source of truth

The translation is anchored to commit `f0974379aeaddb07a9bb7e1c6014774b266b7620`, `android/native/pauli_renderer_orbitals.c`, introduced as “Render hydrogen orbitals in the native viewer.” The file on `main` retains that basic implementation for the translated behavior.

This branch does **not** translate the later Sage symbolic generator or the Idriç level-set ray tracer. Those are separate Pauli paths.

## Layout

- `pauli_orbitals.d` — CPU orbital evaluation, rotation, ray integration, phase coloring, exposure mapping, and 128×128 RGB image generation.
- `pauli_renderer.d` — the original GLES2 texture/shader wrapper and exported `pauli_renderer_*` C ABI, expressed directly in D without a third-party GL binding package.
- `check.d` — D pixel receipts for s/p/d/f plus a rotated p state.
- `reference_check.c` — compiles the retained C source itself and checks the same pixel receipts.
- `reference_include/GLES2/gl2.h` — declarations used only to compile the C reference check without assuming a system GLES development package.

The D core starts on p, cycles p → d → f → s, clamps pitch to ±1.45, uses 28 samples per ray, and retains the original constants and float operations.

## Check

```sh
sh ./d/basic/check.sh
```

The check runs the retained C receipts, runs the D receipts, and compiles the GLES2 D wrapper to an object file. A graphics context is deliberately not required for the numerical acceptance test.
