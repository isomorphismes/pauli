module pauli_orbitals;

import core.stdc.math : cosf, expf, floorf, sinf, sqrtf;

public enum int render_side = 128;
public enum int ray_steps = 28;

public enum float background_red = 0.075f;
public enum float background_green = 0.090f;
public enum float background_blue = 0.115f;

private enum float pi_value = 3.14159265358979323846f;
private enum float view_half_extent = 1.08f;

private enum float positive_red = 0.18f;
private enum float positive_green = 0.68f;
private enum float positive_blue = 1.00f;

private enum float negative_red = 1.00f;
private enum float negative_green = 0.35f;
private enum float negative_blue = 0.12f;

struct OrbitalState {
    private int current_family = 1;
    private float yaw = 0.0f;
    private float pitch = 0.0f;

    void drag(float delta_x, float delta_y) {
        yaw += 4.0f * delta_x;
        pitch += 4.0f * delta_y;

        if (pitch > 1.45f) {
            pitch = 1.45f;
        }
        if (pitch < -1.45f) {
            pitch = -1.45f;
        }
    }

    void cycle_orbital() {
        current_family = (current_family + 1) % 4;
    }

    void render_pixels(ubyte[] output) const {
        assert(output.length >= render_side * render_side * 3);

        foreach (pixel_y; 0 .. render_side) {
            foreach (pixel_x; 0 .. render_side) {
                const offset = 3 * (pixel_y * render_side + pixel_x);
                render_pixel(pixel_x, pixel_y, output[offset .. offset + 3]);
            }
        }
    }

    private void rotate_into_orbital(
        float x,
        float y,
        float z,
        out float orbital_x,
        out float orbital_y,
        out float orbital_z
    ) const {
        const cos_yaw = cosf(yaw);
        const sin_yaw = sinf(yaw);
        const cos_pitch = cosf(pitch);
        const sin_pitch = sinf(pitch);

        const yaw_x = cos_yaw * x + sin_yaw * z;
        const yaw_z = -sin_yaw * x + cos_yaw * z;

        orbital_x = yaw_x;
        orbital_y = cos_pitch * y - sin_pitch * yaw_z;
        orbital_z = sin_pitch * y + cos_pitch * yaw_z;
    }

    private void family_parameters(
        out float physical_radius,
        out float gain
    ) const {
        switch (current_family) {
            case 0:
                physical_radius = 6.0f;
                gain = 35.0f;
                break;
            case 1:
                physical_radius = 8.0f;
                gain = 90.0f;
                break;
            case 2:
                physical_radius = 18.0f;
                gain = 0.06f;
                break;
            default:
                physical_radius = 30.0f;
                gain = 0.00045f;
                break;
        }
    }

    private float orbital_density_and_phase(
        float x,
        float y,
        float z,
        float radius,
        out bool negative_phase
    ) const {
        negative_phase = false;

        switch (current_family) {
            case 0:
                return expf(-2.0f * radius) / pi_value;

            case 1:
                negative_phase = x < 0.0f;
                return x * x * expf(-radius) / (32.0f * pi_value);

            case 2:
                const shape = x * y;
                negative_phase = shape < 0.0f;
                return shape * shape * expf((-2.0f / 3.0f) * radius);

            default:
                const shape = x * y * z;
                negative_phase = shape < 0.0f;
                return shape * shape * expf(-0.5f * radius);
        }
    }

    private void render_pixel(
        int pixel_x,
        int pixel_y,
        ubyte[] output
    ) const {
        const u =
            -view_half_extent +
            2.0f * view_half_extent *
            (cast(float) pixel_x + 0.5f) /
            cast(float) render_side;
        const v =
            -view_half_extent +
            2.0f * view_half_extent *
            (cast(float) pixel_y + 0.5f) /
            cast(float) render_side;

        const radial_squared = u * u + v * v;
        if (radial_squared >= 1.0f) {
            output[0] = channel_to_byte(background_red);
            output[1] = channel_to_byte(background_green);
            output[2] = channel_to_byte(background_blue);
            return;
        }

        float physical_radius;
        float gain;
        family_parameters(physical_radius, gain);

        const z_limit = sqrtf(1.0f - radial_squared);
        const normalized_step = 2.0f * z_limit / cast(float) ray_steps;
        const physical_step = physical_radius * normalized_step;

        float accumulated_red = 0.0f;
        float accumulated_green = 0.0f;
        float accumulated_blue = 0.0f;

        foreach (sample; 0 .. ray_steps) {
            const z =
                z_limit -
                (cast(float) sample + 0.5f) * normalized_step;

            float rotated_x;
            float rotated_y;
            float rotated_z;
            rotate_into_orbital(
                u,
                v,
                z,
                rotated_x,
                rotated_y,
                rotated_z
            );

            const x = physical_radius * rotated_x;
            const y = physical_radius * rotated_y;
            const z_physical = physical_radius * rotated_z;
            const radius =
                physical_radius * sqrtf(radial_squared + z * z);

            bool negative_phase;
            const density = orbital_density_and_phase(
                x,
                y,
                z_physical,
                radius,
                negative_phase
            );

            const red = negative_phase ? negative_red : positive_red;
            const green = negative_phase ? negative_green : positive_green;
            const blue = negative_phase ? negative_blue : positive_blue;

            accumulated_red += density * red * physical_step;
            accumulated_green += density * green * physical_step;
            accumulated_blue += density * blue * physical_step;
        }

        const mapped_red = 1.0f - expf(-gain * accumulated_red);
        const mapped_green = 1.0f - expf(-gain * accumulated_green);
        const mapped_blue = 1.0f - expf(-gain * accumulated_blue);

        output[0] = channel_to_byte(background_red + mapped_red);
        output[1] = channel_to_byte(background_green + mapped_green);
        output[2] = channel_to_byte(background_blue + mapped_blue);
    }
}

private ubyte channel_to_byte(float value) {
    return cast(ubyte) floorf(255.0f * clamp_channel(value) + 0.5f);
}

private float clamp_channel(float value) {
    if (value < 0.0f) {
        return 0.0f;
    }
    if (value > 1.0f) {
        return 1.0f;
    }
    return value;
}
