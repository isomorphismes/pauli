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
