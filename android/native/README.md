# Native orbital renderer

The native viewer is split by purpose.

## Read these files in this order

1. `pauli_renderer_orbitals.c`
   - coordinates the viewer;
   - remembers the selected orbital and rotation;
   - responds to start, drag, tap, draw, and stop.

2. `pauli_orbital.c`
   - contains the current orbital formulas;
   - given an orbital and a point, returns density and phase sign;
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
Android touch or draw
        ↓
pauli_renderer_orbitals.c
        ↓
pauli_volume_image.c
        ↓
pauli_orbital.c
        ↓
pauli_color.c
        ↓
RGB pixels
        ↓
pauli_gles_image.c
        ↓
screen
```

The split is intended to make each part independently criticizable. It does
not claim that the present orbital formulas, render profiles, colors, or
volume algorithm are the final design.
