# Android acceptance

The Android track has two separate acceptance stages.

## 1. Shell smoke acceptance

This stage proves only the application boundary.

Build the APK with the smoke renderer, install it through the normal Android package installer, and launch it.

Required observations:

- Activity launches without a Java/Kotlin application layer;
- APK contains no `classes.dex`;
- `libpauli.so` loads;
- NativeActivity reaches `android_main`;
- EGL surface/context is created;
- a first frame is presented;
- dragging changes the smoke-renderer response;
- a tap cycles through four smoke states;
- switching away and back recreates the surface without crashing;
- rotating/resizing the device recreates or resizes the surface without crashing.

The smoke renderer is not an orbital test.

## Explanation-link acceptance

The optional **Why is this happening?** control is a browser handoff, not an embedded teaching surface.

Acceptance requires:

- the orbital viewer launches and renders with no network connection;
- rendering and rotation do not depend on the explanatory site;
- activating the explanation control asks Android to open the configured URL externally;
- failure to resolve or load that URL does not crash or disable the viewer;
- returning from the browser restores the viewer normally;
- no WebView or notebook runtime is required in the APK.

## 2. Orbital viewer acceptance

Once the real renderer implements `pauli_renderer.h`, the physical test becomes:

1. launch directly into a visible orbital;
2. drag continuously and observe smooth rotation;
3. tap/select representative s, p, d, and f states;
4. verify orbital selection does not compile a new shader in the interaction path;
5. verify drag does not perform symbolic algebra or allocate a new orbital representation;
6. switch away and back without losing the selected state unexpectedly;
7. repeat after process death/relaunch.

The acceptance set should include at least one state from each angular family through `l = 3`.

## Timing receipt

Record these timestamps from the native side:

- NativeActivity/native entry;
- EGL ready;
- renderer ready;
- first frame submitted;
- first frame swap completed.

The useful cold-start number is native entry to first completed swap.

Do not include build time, installation time, or package-manager extraction in the launch measurement.

## Device lanes

The primary phone package is `armeabi-v7a`.

The tablet follower is `arm64-v8a`.

An `x86_64` emulator lane is useful for automated lifecycle/input/package checks, but it is not evidence for the phone GPU.

## Installation

The ordinary user path is an APK, not a development shell.

A stable signing key should be reused so a newer APK can update the installed app rather than requiring uninstall/reinstall.

The physical-phone acceptance path does not require ADB. ADB can remain a CI/emulator or developer convenience.

## Receipt fields

A physical receipt should contain:

```text
source.commit
apk.sha256
abi
android.api
egl.version
gles.version
glsl.version
gl.vendor
gl.renderer
activity.entered
native.library.loaded
egl.ready
renderer.ready
first.frame
native_entry_to_first_swap_ms
drag.rotate
select.s
select.p
select.d
select.f
acceptance
```

Do not promote an emulator screenshot into physical GPU evidence.
