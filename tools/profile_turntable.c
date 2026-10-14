/* Produce a recorded camera turntable using Pauli's actual native CPU
 * orbital evaluator and volume renderer. The quantum state is fixed.
 * Media assembly belongs to isomorphisms/kitchen, not to this program.
 */
#include <stdint.h>
#include <stdio.h>

#include "pauli_orbital.h"
#include "pauli_volume_image.h"

enum { FRAME_COUNT = 32, IMAGE_SIDE = PAULI_VOLUME_IMAGE_SIDE };
static uint8_t pixels[IMAGE_SIDE * IMAGE_SIDE * 3];

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "usage: profile_turntable FRAME_DIRECTORY\n");
        return 2;
    }

    const struct pauli_orbital_demo *demo = pauli_orbital_demo_at(1);
    if (demo == NULL) {
        fputs("Pauli 2p_x state is missing\n", stderr);
        return 1;
    }

    for (int frame = 0; frame < FRAME_COUNT; ++frame) {
        /* One revolution of the camera around a FIXED 2p_x state. */
        const float yaw = 6.2831853071795864769f *
            (float)frame / (float)FRAME_COUNT;
        const float pitch = 0.18f;
        pauli_volume_render_image(&demo->state, yaw, pitch, pixels);

        char filename[4096];
        const int written = snprintf(filename, sizeof filename,
            "%s/frame-%06d.ppm", argv[1], frame);
        if (written < 0 || (size_t)written >= sizeof filename) {
            fputs("frame pathname is too long\n", stderr);
            return 1;
        }

        FILE *output = fopen(filename, "wb");
        if (output == NULL) {
            perror(filename);
            return 1;
        }
        if (fprintf(output, "P6\n%d %d\n255\n",
                    IMAGE_SIDE, IMAGE_SIDE) < 0 ||
            fwrite(pixels, 1, sizeof pixels, output) != sizeof pixels) {
            perror("write frame");
            fclose(output);
            return 1;
        }
        if (fclose(output) != 0) {
            perror("close frame");
            return 1;
        }
    }

    printf("frames=%d width=%d height=%d state=%s camera=yaw(0..2pi) pitch=0.18\n",
        FRAME_COUNT, IMAGE_SIDE, IMAGE_SIDE, demo->name);
    return 0;
}
