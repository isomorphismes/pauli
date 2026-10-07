# Native orbital renderer

The native viewer is split by purpose.

## Read these files in this order

1. `pauli_renderer_orbitals.c`
   - coordinates the viewer;
   - remembers a demonstration position and rotation;
   - passes the catalogue's explicit hydrogen state to volume rendering;
   - responds to start, drag, tap, draw, and stop.

2. `pauli_orbital.c`
   - validates `energy_level` n, `angular_degree` ℓ, `axis_component` m and basis;
   - calls the generated `pauli_hydrogen_spdf_f64` at spherical coordinates;
   - applies the documented real-basis transform, returning magnitude/phase,
     density = magnitude², and a phase-sign projection for the present colors;
   - contains no Android, GLES, pixel, or color code.

3. `pauli_color.c`
   - contains the background and phase colors;
   - contains the volume tone mapping;
   - converts floating RGB values to 8-bit pixels;
   - contains no orbital formulas or GLES code.

4. `pauli_volume_image.c`
   - turns one orbital into a 128 × 128 RGB image;
   - rotates sample points;
   - walks rays through the bounded volume;
   - asks `pauli_orbital.c` for the field value;
   - asks `pauli_color.c` how to color the accumulated result.

5. `pauli_gles_image.c`
   - uploads a finished RGB image as a GLES texture;
   - draws that texture to the current Android EGL surface;
   - contains no hydrogen formulas or ray integration.

`pauli_android.c` remains outside this group. It owns the Android
NativeActivity/EGL/input lifecycle and talks to the renderer only through
`pauli_renderer.h`.

## Main call path

```text
selected catalogue state (n, ℓ, m, basis)
        ↓
pauli_volume_image.c: rotate sample coordinates only
        ↓
pauli_orbital.c: Cartesian → spherical coordinates
        ↓
build/generated/hydrogen_spdf_f64.h: checked amplitude
        ↓
pauli_orbital.c: explicit basis transform → magnitude/phase → density
        ↓
pauli_volume_image.c: 28 bounded ray samples
        ↓
pauli_color.c: phase-sign color, integration gain, tone mapping
        ↓
RGB pixels
        ↓
pauli_gles_image.c
        ↓
screen
```

Android owns lifecycle/input through `pauli_renderer.h`; it knows no hydrogen
formulas. GLES owns presentation and compiles its image shader only at start.
The generated evaluator knows no cameras, pixels, Android or GLES.

## State and real-basis convention

Use atomic units (Bohr radius = 1) and the checked Condon–Shortley convention
ψ₋ₘ = (−1)ᵐ conjugate(ψₘ). A spherical state stores signed m. For a real
state, positive m labels the fixed ±m pair, not a single axis eigenvalue:

| Demo | (n, ℓ, m, basis) | Exact checked-basis combination |
| --- | --- | --- |
| 1s | (1, 0, 0, spherical) | ψ₀ |
| 2pₓ | (2, 1, 1, cosine) | (ψ₋₁ − ψ₁)/√2 |
| 3dₓᵧ | (3, 2, 2, sine) | i(ψ₋₂ − ψ₂)/√2 |
| 4fₓᵧ𝓏 | (4, 3, 2, sine) | i(ψ₋₂ − ψ₂)/√2 |

In general cosine = √2(−1)ᵐ Re(ψₘ) and sine = √2(−1)ᵐ Im(ψₘ).
Runtime projects directly from polar storage. These are fixed basis changes;
no arbitrary superposition UI or editable coefficient model is introduced.
Zero phase is canonical at a zero amplitude. Node roundoff is compared with
an absolute tolerance, without treating undefined node phase as evidence.

The four-state catalogue is UI iteration only. Validation admits exactly the
generated n ≤ 4 domain and rejects invalid quantum numbers, unknown basis
tags, nonpositive real-pair m, and nonfinite coordinates. Invalid samples
contain NaNs and contribute no light. A state outside the demonstration
catalogue has no display profile and produces background.

Rotation evaluates the same const state at rotated coordinates; it never
changes coefficients, regenerates expressions, or allocates state data.
The first state remains 2pₓ, followed by 3dₓᵧ, 4fₓᵧ𝓏, 1s on taps.

The old s/p densities were normalized. The old d/f densities omitted factors
2/(6561π) and 1/(786432π). Those handwritten formulas are removed. Display
gain absorbs the inverse factors, preserving brightness and lobe shapes
while density now has the checked physical normalization.

## Generated build boundary and checks

`.github/actions/hydrogen-f64` explicitly generates the header and numeric
receipts with SageMath 10.8 before native compilation. It repeats generation
and demands byte equality. Generated source is a build output, not committed
or silently regenerated during APK packaging. The native build requires the
header and verifies the generator-source digest manifest; stale/missing
inputs fail closed. `PAULI_GENERATED_DIRECTORY` can select an already generated
absolute directory. A custom smoke renderer does not require hydrogen data.

The APK contains compiled F64 native code only. Sage, SymPy, Python, receipt
files and host checks remain on the build host. The generated header bounds
the evaluator to 30 checked states; the viewer exposes only four.

The generation action checks the generated evaluator's 90 Sage receipts and
compiles the real application adapter, volume renderer, color code and event
coordinator with warnings as errors. `export_viewer_receipts.py` independently
checks the real-basis identities with SymPy and checks Sage/SymPy values at
deterministic Cartesian points, including negative lobes. The application
check covers 40 viewer receipts, origin/axes, invalid inputs, visible images
for every demo, const-state rotation, reproducibility, immediate first image,
tap wrapping and uploads only after interaction. Its GLES presentation stub
is host evidence; actual GLES/package/lifecycle evidence comes separately
from the Android workflow and physical acceptance.
