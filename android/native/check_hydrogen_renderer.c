/* Host acceptance of the same mathematical and event paths as the APK. */
#include "pauli_orbital.h"
#include "pauli_volume_image.h"
#include "pauli_renderer.h"
#include "pauli_gles_image.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define REQUIRE(condition) do { if (!(condition)) { \
    fprintf(stderr, "FAIL line %d: %s\n", __LINE__, #condition); exit(1); \
} } while (0)

static void compare(struct pauli_orbital_sample sample, double magnitude, double phase) {
    REQUIRE(isfinite(sample.amplitude.magnitude));
    REQUIRE(isfinite(sample.amplitude.phase));
    REQUIRE(sample.amplitude.magnitude >= 0.0);
    REQUIRE(fabs(sample.amplitude.magnitude-magnitude) < 3e-12 * (1.0+magnitude));
    REQUIRE(fabs(sample.density-magnitude*magnitude) < 3e-12 * (1.0+magnitude*magnitude));
    REQUIRE(sample.density == sample.amplitude.magnitude * sample.amplitude.magnitude);
    if (magnitude > 1e-14) {
        double difference = sample.amplitude.phase-phase;
        REQUIRE(fabs(atan2(sin(difference), cos(difference))) < 3e-12);
        REQUIRE(sample.negative_phase == (cos(phase) < 0.0));
    }
}

static void check_spherical_receipts(const char *path) {
    FILE *input = fopen(path, "r");
    REQUIRE(input != NULL);
    int n, degree, component, count = 0;
    double radius, theta, phi, magnitude, phase;
    while (fscanf(input, "%d%d%d%lf%lf%lf%lf%lf", &n, &degree, &component,
                  &radius, &theta, &phi, &magnitude, &phase) == 8) {
        const struct pauli_hydrogen_state state = {n, degree, component, PAULI_SPHERICAL};
        compare(pauli_orbital_sample_at(&state, radius*sin(theta)*cos(phi),
                    radius*sin(theta)*sin(phi), radius*cos(theta)), magnitude, phase);
        ++count;
    }
    REQUIRE(feof(input));
    REQUIRE(count == 90);
    fclose(input);
}

static void check_viewer_receipts(const char *path) {
    FILE *input = fopen(path, "r");
    REQUIRE(input != NULL);
    size_t index;
    double x, y, z, magnitude, phase;
    int counts[4] = {0};
    while (fscanf(input, "%zu%lf%lf%lf%lf%lf", &index, &x, &y, &z, &magnitude, &phase) == 6) {
        REQUIRE(index < 4);
        const struct pauli_orbital_demo *demo = pauli_orbital_demo_at(index);
        REQUIRE(demo != NULL);
        REQUIRE(pauli_orbital_demo_index(&demo->state) == (int)index);
        compare(pauli_orbital_sample_at(&demo->state, x, y, z), magnitude, phase);
        ++counts[index];
    }
    REQUIRE(feof(input));
    for (index = 0; index < 4; ++index) REQUIRE(counts[index] == 10);
    fclose(input);
}

static void check_invalid(void) {
    const struct pauli_hydrogen_state invalid[] = {
        {0,0,0,PAULI_SPHERICAL}, {5,0,0,PAULI_SPHERICAL},
        {2,2,0,PAULI_SPHERICAL}, {2,-1,0,PAULI_SPHERICAL},
        {2,1,2,PAULI_SPHERICAL}, {2,1,-2,PAULI_SPHERICAL},
        {2,1,0,PAULI_REAL_SINE}, {2,1,-1,PAULI_REAL_COSINE},
        {1,0,0,(enum pauli_hydrogen_basis)99}
    };
    for (size_t index = 0; index < sizeof invalid/sizeof invalid[0]; ++index) {
        REQUIRE(!pauli_hydrogen_state_valid(&invalid[index]));
        REQUIRE(isnan(pauli_orbital_sample_at(&invalid[index], 1,2,3).density));
        REQUIRE(pauli_orbital_demo_index(&invalid[index]) == -1);
    }
    REQUIRE(!pauli_hydrogen_state_valid(NULL));
    REQUIRE(isnan(pauli_orbital_sample_at(NULL, 1,2,3).density));
    REQUIRE(pauli_orbital_demo_at(4) == NULL);
    REQUIRE(pauli_orbital_demo_at((size_t)-1) == NULL);
    const struct pauli_hydrogen_state *valid = &pauli_orbital_demo_at(1)->state;
    REQUIRE(isnan(pauli_orbital_sample_at(valid, NAN,2,3).density));
    REQUIRE(isnan(pauli_orbital_sample_at(valid, 1,INFINITY,3).density));
    REQUIRE(isnan(pauli_hydrogen_spdf_f64(5,0,0,1,1,1).magnitude));
}

enum { IMAGE_BYTES = PAULI_VOLUME_IMAGE_SIDE*PAULI_VOLUME_IMAGE_SIDE*3 };
static uint8_t presented[IMAGE_BYTES];
static int starts, uploads, draws;
/* Stub only presentation; math, volume integration and coordinator are real. */
int pauli_gles_image_start(int width, int height, int side, const uint8_t *pixels) {
    REQUIRE(width > 0 && height > 0 && side == PAULI_VOLUME_IMAGE_SIDE);
    memcpy(presented, pixels, IMAGE_BYTES); ++starts; return 1;
}
void pauli_gles_image_upload(int side, const uint8_t *pixels) {
    REQUIRE(side == PAULI_VOLUME_IMAGE_SIDE);
    memcpy(presented, pixels, IMAGE_BYTES); ++uploads;
}
void pauli_gles_image_resize(int width, int height) { (void)width; (void)height; }
void pauli_gles_image_draw(void) { ++draws; }
void pauli_gles_image_stop(void) {}

static void check_rendering(void) {
    uint8_t image[IMAGE_BYTES], rotated[IMAGE_BYTES];
    REQUIRE(pauli_orbital_demo_count() == 4);
    for (size_t index = 0; index < 4; ++index) {
        const struct pauli_hydrogen_state *state = &pauli_orbital_demo_at(index)->state;
        const struct pauli_hydrogen_state before = *state;
        pauli_volume_render_image(state, 0, 0, image);
        pauli_volume_render_image(state, 0.4f, -0.3f, rotated);
        REQUIRE(state->energy_level == before.energy_level &&
                state->angular_degree == before.angular_degree &&
                state->axis_component == before.axis_component && state->basis == before.basis);
        int visible = 0;
        for (int pixel = 1; pixel < PAULI_VOLUME_IMAGE_SIDE*PAULI_VOLUME_IMAGE_SIDE; ++pixel)
            if (memcmp(image, image+pixel*3, 3)) ++visible;
        REQUIRE(visible > 100);
        if (index) REQUIRE(memcmp(image, rotated, IMAGE_BYTES) != 0);
        pauli_volume_render_image(state, 0, 0, rotated);
        REQUIRE(memcmp(image, rotated, IMAGE_BYTES) == 0);
    }
    REQUIRE(!pauli_renderer_start(576,1152,1));
    REQUIRE(pauli_renderer_start(576,1152,2));
    pauli_volume_render_image(&pauli_orbital_demo_at(1)->state, 0,0,image);
    REQUIRE(memcmp(image, presented, IMAGE_BYTES) == 0);
    pauli_renderer_draw(); pauli_renderer_draw();
    REQUIRE(uploads == 0 && draws == 2);
    pauli_renderer_drag(0.1f,-0.075f);
    pauli_renderer_draw(); pauli_renderer_draw();
    REQUIRE(uploads == 1 && memcmp(image,presented,IMAGE_BYTES) != 0);
    for (size_t cycle = 0; cycle < 4; ++cycle) {
        pauli_renderer_cycle_orbital(); pauli_renderer_draw();
        pauli_volume_render_image(&pauli_orbital_demo_at((cycle+2)%4)->state, 0.4f,-0.3f,image);
        REQUIRE(memcmp(image,presented,IMAGE_BYTES) == 0);
    }
    REQUIRE(starts == 1 && uploads == 5);
    pauli_renderer_stop();
}

int main(int argc, char **argv) {
    REQUIRE(argc == 3);
    check_spherical_receipts(argv[1]);
    check_viewer_receipts(argv[2]);
    check_invalid(); check_rendering();
    puts("PASS: 90 spherical + 40 real-basis/origin/axis receipts; four rendered states; rotation, event path and invalid inputs");
    return 0;
}
