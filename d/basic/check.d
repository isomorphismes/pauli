module check;

import core.stdc.stdio : printf;
import pauli_orbitals : OrbitalState, render_side;

private ulong fnv1a64(const(ubyte)[] bytes) {
    ulong hash = 14695981039346656037UL;
    foreach (value; bytes) {
        hash ^= value;
        hash *= 1099511628211UL;
    }
    return hash;
}

private bool expect_hash(
    const(char)[] label,
    ulong actual,
    ulong expected
) {
    if (actual == expected) {
        return true;
    }

    printf(
        "FAIL: %.*s hash %016lx expected %016lx\n",
        cast(int) label.length,
        label.ptr,
        actual,
        expected
    );
    return false;
}

int main() {
    ubyte[render_side * render_side * 3] pixels;
    bool ok = true;

    OrbitalState state;
    state.render_pixels(pixels[]);
    ok = expect_hash(
        "family 1",
        fnv1a64(pixels[]),
        0x327df79cfe24b809UL
    ) && ok;

    state.cycle_orbital();
    state.render_pixels(pixels[]);
    ok = expect_hash(
        "family 2",
        fnv1a64(pixels[]),
        0x8dc27d60952d989fUL
    ) && ok;

    state.cycle_orbital();
    state.render_pixels(pixels[]);
    ok = expect_hash(
        "family 3",
        fnv1a64(pixels[]),
        0x823a02c43655199dUL
    ) && ok;

    state.cycle_orbital();
    state.render_pixels(pixels[]);
    ok = expect_hash(
        "family 0",
        fnv1a64(pixels[]),
        0xeaab2b9b7d70be9dUL
    ) && ok;

    OrbitalState dragged;
    dragged.drag(0.125f, -0.2f);
    dragged.render_pixels(pixels[]);
    ok = expect_hash(
        "dragged family 1",
        fnv1a64(pixels[]),
        0xbde69ea594d8b265UL
    ) && ok;

    if (!ok) {
        return 1;
    }

    printf("PASS: D basic Pauli matches retained C pixel receipts\n");
    return 0;
}
