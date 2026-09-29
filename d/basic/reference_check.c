#include <stdint.h>
#include <stdio.h>

#include "../../android/native/pauli_renderer_orbitals.c"

static uint64_t fnv1a64_reference(void) {
    uint64_t hash = UINT64_C(14695981039346656037);
    for (size_t index = 0; index < sizeof pixels; ++index) {
        hash ^= pixels[index];
        hash *= UINT64_C(1099511628211);
    }
    return hash;
}

static int expect_hash(
    const char *label,
    uint64_t actual,
    uint64_t expected
) {
    if (actual == expected) {
        return 1;
    }

    fprintf(
        stderr,
        "FAIL: %s hash %016llx expected %016llx\n",
        label,
        (unsigned long long)actual,
        (unsigned long long)expected
    );
    return 0;
}

int main(void) {
    int ok = 1;

    current_family = 0;
    yaw = 0.0f;
    pitch = 0.0f;
    render_pixels();
    ok &= expect_hash(
        "family 0",
        fnv1a64_reference(),
        UINT64_C(0xeaab2b9b7d70be9d)
    );

    current_family = 1;
    yaw = 0.0f;
    pitch = 0.0f;
    render_pixels();
    ok &= expect_hash(
        "family 1",
        fnv1a64_reference(),
        UINT64_C(0x327df79cfe24b809)
    );

    current_family = 2;
    yaw = 0.0f;
    pitch = 0.0f;
    render_pixels();
    ok &= expect_hash(
        "family 2",
        fnv1a64_reference(),
        UINT64_C(0x8dc27d60952d989f)
    );

    current_family = 3;
    yaw = 0.0f;
    pitch = 0.0f;
    render_pixels();
    ok &= expect_hash(
        "family 3",
        fnv1a64_reference(),
        UINT64_C(0x823a02c43655199d)
    );

    current_family = 1;
    yaw = 4.0f * 0.125f;
    pitch = 4.0f * -0.2f;
    if (pitch > 1.45f) {
        pitch = 1.45f;
    }
    if (pitch < -1.45f) {
        pitch = -1.45f;
    }
    render_pixels();
    ok &= expect_hash(
        "dragged family 1",
        fnv1a64_reference(),
        UINT64_C(0xbde69ea594d8b265)
    );

    if (!ok) {
        return 1;
    }

    puts("PASS: retained C basic Pauli pixel receipts");
    return 0;
}
