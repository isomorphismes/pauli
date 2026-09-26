# Android fast path

The Android app should feel like an old dedicated scientific viewer, not like a notebook wrapped in a phone UI.

The first useful product is simple:

- open quickly;
- show one hydrogen orbital immediately;
- drag with one finger to rotate it;
- tap to move through a small built-in set of s, p, d, and f examples;
- do no network work;
- do no source parsing or symbolic algebra on the phone.

## Signing identity

APK signing is fail-closed.

`android/build-apk.sh` never generates a keystore and never selects a fallback
key.  A caller must provide the keystore, type, alias, passwords, and the
expected SHA-256 certificate fingerprint.  The script verifies the keystore
certificate before signing, verifies the finished APK signer afterward, and
writes a `.signing.tsv` receipt beside the APK.

The ordinary sideload/test lane currently uses the same stable public test
signer already used by Wegert/Conway. The authoritative package/lane →
certificate mapping lives in the pinned `ai-ci/android-signing` registry, not
in this repository.

CI loads the expected Pauli test fingerprint from that registry, verifies the
keystore certificate before signing, and then runs the pinned central
`android-signing` action against the finished APK before artifact upload.

A missing key, wrong alias, wrong password, changed certificate, multiple or
unexpected APK signer, unregistered package/lane, or missing expected
fingerprint is a build/publication failure. There is no automatic key creation.

A future private release signer is a separate identity.  It must be supplied
explicitly with its own pinned certificate fingerprint; changing from the test
signer to a release signer is an intentional package-signing migration, never
a CI fallback.

## Current status

The Android shell and the first orbital renderer are connected. The default native build renders a 2p_x hydrogen state immediately, rotates it on drag, and cycles representative s, p, d, and f states on tap. The renderer uses a bounded 128 × 128 Float32 CPU volume pass and uploads the packed RGB frame through GLES, keeping Android lifecycle/input code separate behind `pauli_renderer.h`.

`pauli_renderer_smoke.c` remains available as a packaging/input probe, but it is no longer the default application renderer.

Android NDK NativeActivity reference:

https://developer.android.com/ndk/reference/group/native-activity

## Product boundary: viewer on the phone, explanation on the web

The Android application is **not** the course, notebook, derivation, or reference manual.

Its job is deliberately narrow:

- render the selected orbital;
- accept touch input;
- rotate the view/state smoothly;
- allow a very small amount of state selection;
- provide one unobtrusive **Why is this happening?** link.

That link should hand the user to an ordinary external web page in the system browser. Do not embed a WebView and do not make the explanatory site part of the renderer process.

The explanatory page can be long, interactive, and computationally rich: static HTML, a Sage-backed page, notebooks rendered for the web, or whatever later proves useful. None of it is a startup or runtime dependency of the Android viewer.

The viewer must remain fully useful offline except for following that optional explanation link.

This separation is intentional:

```text
Android
    see it
    touch it
    rotate it
    choose another state
          |
          | optional: "Why is this happening?"
          v
browser / explanatory site
    derivation
    symmetry
    history
    calculations
    longer interactive material
```

## Runtime boundary

The preferred installed shape is:

```text
Android framework NativeActivity
          |
          v
libpauli.so
    Android lifecycle + input + EGL
          |
          v
renderer
    one/few fixed GLES programs
          |
          v
precomputed orbital data
```

There is no application DEX layer in the production package. Android's built-in `android.app.NativeActivity` is declared directly in the manifest with `android:hasCode="false"`, and it loads `libpauli.so`.

The native library owns:

- NativeActivity lifecycle;
- the native window;
- touch input;
- EGL context/surface;
- renderer startup and teardown;
- the tiny amount of state needed to select and rotate an orbital.

The renderer should not know about Activity objects, DEX, JNI, package signing, or Android lifecycle details.

## What does not ship in the app

These belong to build-time verification or generation:

- SageMath;
- SymPy;
- JAX;
- Python;
- notebooks;
- the Idriç compiler;
- the DEX encoder;
- symbolic simplification.

The phone receives already checked data/code.

The symbolic scaffold in `symbolic/` is an oracle and generator. It can establish exact normalization, equations, orthogonality, and the s/p/d/f state set. It should then emit the bounded data or expressions required by the renderer.

JAX can be useful off-device for experiments or numerical cross-checks. It is not part of the launch path.

## Rotation is cheap

Dragging the orbital must **not** trigger symbolic recomputation and should not trigger shader recompilation.

The runtime should keep one orientation value and change that value on touch input.

For a renderer that samples an orbital field, rotation can normally be expressed by transforming the sample position (or camera/state frame) before evaluating the fixed field. The orbital data remain unchanged.

So the hot path is roughly:

```text
finger move
  -> update orientation
  -> update a few uniforms
  -> draw
```

No allocation-heavy object graph, no JNI call per pixel, no special-function regeneration.

## Renderer contract

`native/pauli_renderer.h` is the boundary between this Android track and the renderer track.

The Android shell guarantees:

- a current EGL context when renderer functions that require GLES are called;
- current framebuffer dimensions;
- normalized drag deltas;
- event-driven redraw requests;
- clean stop/start across window loss and recreation.

The renderer owns:

- shader programs;
- orbital field evaluation;
- ray tracing / ray marching / isosurface logic;
- orbital selection;
- rotation representation;
- draw calls.

The smoke implementation is only an APK/lifecycle/input probe. It is not an orbital renderer.

## Shader policy

For startup speed, prefer one generic program or a very small fixed set of programs.

Changing from an s orbital to a p/d/f orbital should ideally change uniforms or a compact coefficient/state table, not compile a new shader.

The exact symbolic source can generate a compact table at build time. The current symbolic scaffold already enumerates the ordinary hydrogen states through `l = 3`.

If the eventual ray tracer needs specialization, specialize at build time and package the small fixed set. Do not JIT-generate source on every selection.

## DEX / JNI / NDK roles

### DEX

The production viewer has no `classes.dex`.

Android provides `android.app.NativeActivity` as a framework class, so the manifest can name it directly. This is smaller and removes ART application bytecode from the launch path entirely.

Keep the direct Idriç DEX backend as a separate capability for applications that genuinely need their own framework-facing class logic; Pauli does not.

### JNI

Do not build the renderer around frequent JNI crossings.

NativeActivity already hands the native library the Android native boundary. JNI remains available for occasional framework features, but it should not be the frame loop.

### NDK

Use the NDK for the shared library and final Android API boundary.

The app should build at least:

- `armeabi-v7a`;
- `arm64-v8a`;
- `x86_64` for emulator acceptance.

The fourth public NDK ABI, `x86`, can remain a qualification follower if keeping it costs little.

### GLES

The existing shader work has already exercised EGL/GLES on the physical PowerVR phone and Mali tablet.

Pauli should consume that same kind of boundary: CPU/ABI selection and graphics capability are separate facts.

A GLES 3 path is the natural first production path for the current phones. A GLES 2 fallback can remain a later portability lane if the renderer can support it without contaminating the main design.

## Page-size compatibility

Current Android guidance:

https://developer.android.com/guide/practices/page-sizes


This app contains native code, so 64-bit artifacts must be compatible with 16 KiB Android page sizes.

The native build script uses 16 KiB-compatible load-segment alignment for `arm64-v8a` and `x86_64`.

The debug APK keeps native libraries compressed and extracted at install time. That avoids depending on special in-APK alignment for the local sideload path.

A Play/AAB release lane should separately verify current bundle packaging requirements.

## Target SDK

Current Google Play target-API requirements:

https://developer.android.com/google/play/requirements/target-sdk


The manifest currently targets API 36.

That is an Android packaging/release fact. It does **not** mean the orbital renderer requires Android 16 APIs.

The native API floor remains independent and can stay low as long as the NDK/toolchain lane supports it.

## Current smoke-package size

The first DEX-free single-ABI CI packages are deliberately tiny:

| target | APK | native library |
| --- | ---: | ---: |
| phone `armeabi-v7a` | 20,923 bytes | 27,348 bytes |
| tablet `arm64-v8a` | 20,921 bytes | 28,984 bytes |
| emulator `x86_64` | 20,918 bytes | 28,512 bytes |

These numbers are only the Android-shell/smoke baseline, **before the real orbital renderer is linked**. They are useful as a floor and as evidence that the packaging itself is not dragging in a framework, DEX payload, or extra architectures.

## Startup target

The first frame should require only:

1. ART instantiates the tiny Activity shell;
2. Android loads `libpauli.so`;
3. NativeActivity creates the native thread/window boundary;
4. EGL context/surface is created;
5. the already packaged renderer program is compiled/linked once;
6. the default orbital is drawn.

No file scan, database, network request, notebook kernel, or dynamic language runtime belongs before the first frame.

A later physical receipt should record at least:

- APK SHA-256;
- ABI;
- Android API;
- EGL/GLES/GLSL identity;
- renderer vendor/name;
- Activity entered;
- native library loaded;
- first surface ready;
- first frame presented;
- milliseconds from native entry to first frame.

## First interaction contract

For the minimal app:

- drag: rotate;
- tap: cycle through the built-in demonstration orbital set;
- window recreation: preserve the selected orbital and orientation if practical;
- idle: block waiting for events rather than repainting continuously.

This keeps battery use and latency appropriate for a viewer rather than a game loop.

## Cross-repository inputs

Pauli should reuse rather than duplicate:

- Android ELF/ABI discipline from `dilapidated-shed/ick`;
- EGL/GLES target evidence from `dilapidated-shed/idris-shader-backend`.

The Pauli repository owns the application contract and the orbital renderer integration. The production viewer should stay native-only unless a future feature demonstrates a real need for application DEX.
