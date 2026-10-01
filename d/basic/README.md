# Basic Pauli in D

This is a direct D translation of the retained basic Pauli orbital viewer and
its NativeActivity shell.

## Source of truth

The orbital translation is anchored to commit
`f0974379aeaddb07a9bb7e1c6014774b266b7620`,
`android/native/pauli_renderer_orbitals.c`, introduced as “Render hydrogen
orbitals in the native viewer.”

The Android shell translates `android/native/pauli_android.c`: NativeActivity
lifecycle, EGL setup/teardown, event-driven drawing, drag rotation, and
tap-to-cycle behavior.

This branch does **not** translate the later Sage symbolic generator or the
Idriç level-set ray tracer. Those are separate Pauli paths.

## Layout

- `pauli_orbitals.d` — CPU orbital evaluation, rotation, ray integration,
  phase coloring, exposure mapping, and 128×128 RGB image generation.
- `pauli_renderer.d` — the original GLES2 texture/shader wrapper and exported
  `pauli_renderer_*` C ABI, expressed directly in D.
- `pauli_android.d` — NativeActivity lifecycle/input/EGL shell in BetterC D.
- `android_app_bridge.c` — deliberately tiny ABI adapter around the concrete
  NDK `android_app` and `android_poll_source` struct layouts. Application
  behavior does not live here.
- `check.d` — D pixel receipts for s/p/d/f plus a rotated p state.
- `reference_check.c` — compiles the retained C orbital source itself and
  checks the same pixel receipts.
- `reference_include/GLES2/gl2.h` — declarations used only by the headless C
  receipt check.

The NDK-supplied `android_native_app_glue.c` remains NDK code, as it did in
the original C application.

## Numerical acceptance

```sh
sh ./d/basic/check.sh
```

The retained C implementation and the D implementation must produce identical
whole-image hashes for all four built-in families and a rotated p state.

## Android BetterC build

```sh
ANDROID_ABI=armeabi-v7a \
    bash ./android/build-native-d.sh
```

The D application is compiled with LDC `-betterC`, then linked by the Android
NDK toolchain with the NDK NativeActivity glue and Android/EGL/GLES libraries.
There is no D runtime or garbage collector in the intended shared library.

CI separately compiles the D sources as BetterC and cross-links an Android
`libpauli.so`. That catches unresolved druntime references instead of merely
checking D syntax.

The D core retains the original default p state, p → d → f → s cycling,
±1.45 pitch clamp, 28 samples per ray, and the original rendering constants.


## Icky D compiler lanes

Pauli is now an Icky D consumer rather than treating LDC as the language
authority.

The CI workflow `.github/workflows/icky-d-pauli.yml` pins and exercises:

- Icky DMD Android ARM backend commit
  `edeecb0ad920bd6aa29ee0c757e3d12f39e674e1`;
- Icky GDC baseline commit
  `af2049f9d07a7ba48c104d933a6fe90500f8e9c1`.

`pauli_leaf.d` is production orbital math factored specifically so the current
Icky DMD Android leaf boundary can compile the same code used by the full
renderer. It contains radial, p/d/f polynomial, sign, and channel-clamp
operations. The renderer imports and calls those functions.

Both owned Icky D compilers also compile the complete basic D source set on the
host without druntime/Phobos. `icky_check.d` links the orbital core with the
system C linker and libm and checks the same whole-image receipts.

The remaining Icky D Android gap is therefore narrower than "compile D":
the current DMD ARM/AArch64 leaf boundary does not yet admit the renderer's
external math/GLES/EGL calls, aggregate state, byte RGB stores, global renderer
state, or full NativeActivity shell. LDC remains a temporary Android object
compiler for those pieces while that Icky D boundary is expanded. The Android
NDK remains the final linker/ABI authority.
