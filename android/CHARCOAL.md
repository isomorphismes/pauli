# Charcoal application windows and explanation pages

The native launch/splash window and system-bar policy use the fixed shared
Android theme from `isomorphisms/android-NDK` source
`3e682fb1175beef5625dbd2418730220e49fc9bd`. Both APK producers check that source
out at `.charcoal` and stage its presentation resources into `android/res/`.
A direct local package build requires the same resource staging. The existing
APK packager compiles this resource directory before its existing link/sign
steps; it retains the package, version, registered signer and fullscreen policy.

The scientific orbital image, phase-sign colors, tone mapping, generated
hydrogen evaluator and interaction behavior are unchanged. That scientific
canvas is not subjected to a whole-frame charcoal threshold or pixel filter.

The two application-owned explanation pages use one local `charcoal.css` with
explicit charcoal/light text, restrained dividers, selection and keyboard focus.
They no longer select a light default from the browser's system setting. Their
mathematical text, diagrams, figures and external links retain their content.
No publication of the pages is performed.

Compilation, package signing, actual Android execution, independent visual
acceptance and physical C67 acceptance are distinct results. API 29/34 both-mode
launch/chrome checks, startup-transition sequences, rotation and physical C67
acceptance remain outstanding until the corresponding candidate is executed.
An ARM64 APK is a C67 candidate; its ABI does not establish tablet or C67 physical
behavior. A1 ARM32 acceptance remains separate.
