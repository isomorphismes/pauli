module icky_check;

import pauli_orbitals : OrbitalState, render_side;

private ulong fnv1a64(const(ubyte)[] bytes) {
    ulong hash = 14695981039346656037UL;
    foreach (value; bytes) {
        hash ^= value;
        hash *= 1099511628211UL;
    }
    return hash;
}

extern(C) int main() {
    ubyte[render_side * render_side * 3] pixels;

    OrbitalState state;
    state.render_pixels(pixels[]);
    if (fnv1a64(pixels[]) != 0x327df79cfe24b809UL) {
        return 11;
    }

    state.cycle_orbital();
    state.render_pixels(pixels[]);
    if (fnv1a64(pixels[]) != 0x8dc27d60952d989fUL) {
        return 12;
    }

    state.cycle_orbital();
    state.render_pixels(pixels[]);
    if (fnv1a64(pixels[]) != 0x823a02c43655199dUL) {
        return 13;
    }

    state.cycle_orbital();
    state.render_pixels(pixels[]);
    if (fnv1a64(pixels[]) != 0xeaab2b9b7d70be9dUL) {
        return 10;
    }

    OrbitalState dragged;
    dragged.drag(0.125f, -0.2f);
    dragged.render_pixels(pixels[]);
    if (fnv1a64(pixels[]) != 0xbde69ea594d8b265UL) {
        return 14;
    }

    return 0;
}
