# Division syntax and compiler stages

Maintained Idriç raytracer arithmetic uses `÷` with pinned Idriç
`94dfd99bd3e376507fedc8611053b7173b2519f0`. Its original and migrated 64×48
hydrogen 2p PPM outputs were byte-identical. The one-step compiler handoff and
the existing Idriç raytracer checks pass separately from Android evidence.

The Android source has twelve binary division sites across the lifecycle,
orbital adapter, volume integration, GLES presentation, smoke renderer and
host acceptance check. They now use literal `÷`. SymPy's C expression output
also spells its binary division with `÷`; this replacement is scoped to pure
generated arithmetic expressions, preserving operation order. Shader strings
and non-C symbolic algebra keep their own language syntax.

The exact C frontend is ICK `c61e448251744a2f40ad743ebef1a027bdcd2f9d`;
the shared producer is ai-ci `903b2cb27ea572c9c6cb2ffa9f39e0fbf06ec9f8`.
Every maintained Android C translation unit is compiled by ICK to assembly,
which NDK `29.0.14206865` assembles and links with its unmodified
`native_app_glue`. The API21 floor, three original ABI packages, warnings as
errors, optimization, stable test signing and emulator acceptance remain.
Compiler builtin headers precede the Bionic sysroot deterministically.
This direct build does not inject CMake's Fortify setting; no existing
hardening flag is removed and no API-floor increase is required.

The host generation action builds the exact ICK compiler, executes the shared
stage contract and then runs its existing Sage/SymPy checks, deterministic
generation and C receipt checks. It rejects absent/stale generated artifacts
before Android compilation. Installed cross compilers travel between jobs as
tar archives, retaining executable bits, and their target is checked on
restore. No maintained C falls back to stock `cc` or NDK C compilation.

Sage's existing Python-family generator programs and the existing Python
orchestration in `hydrogen-f64` remain named Python-to-Ithon migration debt.
This division change adds no Python program and preserves the established
Sage/SymPy semantic path; C compiler and expression spelling changes are
localized to that existing boundary.

Local evidence uses the exact unchanged-generator artifact from main
`11fa8e1dfbfdfbf776ec26ae0d5656aadc090b8e`, run `37561652594`, artifact
`11456862955`. Its generator digest manifest matched the source before the
expression spelling change. The original and migrated application C both
pass all 90 spherical and 40 viewer receipts plus the four rendered-state,
rotation, event-path and invalid-input checks with ICK. Fresh generation with
the changed producer must pass the hosted Sage path; the retained old
generated artifact is not evidence that the new producer executed.

The r29/API21 ARM smoke library and AArch64 complete orbital library compile,
assemble and link locally through the new route, with warnings as errors.
The latter uses that explicitly identified prior generated header; the hosted
builds require the newly generated, digest-checked header.

APK publication, emulator behavior and physical-device acceptance are distinct
from compilation and host receipts. Keep the physical obligations in
`ACCEPTANCE.md` in force.
