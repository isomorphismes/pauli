#include "pauli_volume_image.h"

#include <math.h>

#include "pauli_color.h"

#define RAY_STEPS 28

static const float view_half_extent = 1.08f;

struct pauli_render_profile {
    float physical_radius;
    float gain;
};

static struct pauli_render_profile render_profile_for(
    enum pauli_orbital orbital
) {
    switch (orbital) {
        case PAULI_ORBITAL_1S:
            return (struct pauli_render_profile) {
                .physical_radius = 6.0f,
                .gain = 35.0f
            };

        case PAULI_ORBITAL_2P_X:
            return (struct pauli_render_profile) {
                .physical_radius = 8.0f,
                .gain = 90.0f
            };

        case PAULI_ORBITAL_3D_XY:
            return (struct pauli_render_profile) {
                .physical_radius = 18.0f,
                .gain = 0.06f
            };

        case PAULI_ORBITAL_4F_XYZ:
        default:
            return (struct pauli_render_profile) {
                .physical_radius = 30.0f,
                .gain = 0.00045f
            };
    }
}

static void rotate_into_orbital(
    float x,
    float y,
    float z,
    float yaw,
    float pitch,
    float *orbital_x,
    float *orbital_y,
    float *orbital_z
) {
    const float cos_yaw = cosf(yaw);
    const float sin_yaw = sinf(yaw);
    const float cos_pitch = cosf(pitch);
    const float sin_pitch = sinf(pitch);

    const float yaw_x = cos_yaw * x + sin_yaw * z;
    const float yaw_z = -sin_yaw * x + cos_yaw * z;

    *orbital_x = yaw_x;
    *orbital_y = cos_pitch * y - sin_pitch * yaw_z;
    *orbital_z = sin_pitch * y + cos_pitch * yaw_z;
}

static struct pauli_rgb integrate_ray(
    enum pauli_orbital orbital,
    float u,
    float v,
    float yaw,
    float pitch,
    struct pauli_render_profile profile
) {
    const float radial_squared = u * u + v * v;
    const float z_limit = sqrtf(1.0f - radial_squared);
    const float normalized_step =
        2.0f * z_limit / (float)RAY_STEPS;
    const float physical_step =
        profile.physical_radius * normalized_step;

    struct pauli_rgb accumulated = {
        .red = 0.0f,
        .green = 0.0f,
        .blue = 0.0f
    };

    for (int sample_index = 0;
         sample_index < RAY_STEPS;
         ++sample_index) {
        const float ray_z =
            z_limit -
            ((float)sample_index + 0.5f) *
            normalized_step;

        float orbital_x = 0.0f;
        float orbital_y = 0.0f;
        float orbital_z = 0.0f;

        rotate_into_orbital(
            u,
            v,
            ray_z,
            yaw,
            pitch,
            &orbital_x,
            &orbital_y,
            &orbital_z
        );

        const struct pauli_orbital_sample sample =
            pauli_orbital_sample_at(
                orbital,
                profile.physical_radius * orbital_x,
                profile.physical_radius * orbital_y,
                profile.physical_radius * orbital_z
            );

        const struct pauli_rgb emitted =
            pauli_color_scale(
                pauli_phase_color(sample.negative_phase),
                sample.density * physical_step
            );

        accumulated =
            pauli_color_add(accumulated, emitted);
    }

    return accumulated;
}

static void render_pixel(
    enum pauli_orbital orbital,
    int pixel_x,
    int pixel_y,
    float yaw,
    float pitch,
    struct pauli_render_profile profile,
    uint8_t output[3]
) {
    const float u =
        -view_half_extent +
        2.0f * view_half_extent *
        ((float)pixel_x + 0.5f) /
        (float)PAULI_VOLUME_IMAGE_SIDE;

    const float v =
        -view_half_extent +
        2.0f * view_half_extent *
        ((float)pixel_y + 0.5f) /
        (float)PAULI_VOLUME_IMAGE_SIDE;

    const float radial_squared = u * u + v * v;

    if (radial_squared >= 1.0f) {
        pauli_color_to_rgb8(
            pauli_background_color(),
            output
        );
        return;
    }

    const struct pauli_rgb accumulated =
        integrate_ray(
            orbital,
            u,
            v,
            yaw,
            pitch,
            profile
        );

    pauli_color_to_rgb8(
        pauli_finish_volume_color(
            accumulated,
            profile.gain
        ),
        output
    );
}

void pauli_volume_render_image(
    enum pauli_orbital orbital,
    float yaw,
    float pitch,
    uint8_t *pixels
) {
    const struct pauli_render_profile profile =
        render_profile_for(orbital);

    for (int y = 0; y < PAULI_VOLUME_IMAGE_SIDE; ++y) {
        for (int x = 0; x < PAULI_VOLUME_IMAGE_SIDE; ++x) {
            render_pixel(
                orbital,
                x,
                y,
                yaw,
                pitch,
                profile,
                &pixels[
                    3 *
                    (
                        y * PAULI_VOLUME_IMAGE_SIDE +
                        x
                    )
                ]
            );
        }
    }
}
