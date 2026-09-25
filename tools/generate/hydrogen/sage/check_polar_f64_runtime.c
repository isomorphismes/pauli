#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include "hydrogen_spdf_f64.h"

static double
phase_difference(
    double left,
    double right
)
{
    const double difference =
        left - right;

    return atan2(
        sin(difference),
        cos(difference)
    );
}

int
main(int argc, char **argv)
{
    FILE *receipts;
    int energy_level;
    int angular_degree;
    int axis_component;
    double radius;
    double polar_angle;
    double azimuth;
    double expected_magnitude;
    double expected_phase;
    int checked = 0;

    if (argc != 2) {
        fprintf(
            stderr,
            "usage: %s polar_f64_receipts.tsv\n",
            argv[0]
        );
        return 2;
    }

    receipts = fopen(argv[1], "r");

    if (receipts == NULL) {
        perror("fopen");
        return 2;
    }

    while (
        fscanf(
            receipts,
            "%d%d%d%lf%lf%lf%lf%lf",
            &energy_level,
            &angular_degree,
            &axis_component,
            &radius,
            &polar_angle,
            &azimuth,
            &expected_magnitude,
            &expected_phase
        ) == 8
    ) {
        const pauli_complex_f64 actual =
            pauli_hydrogen_spdf_f64(
                energy_level,
                angular_degree,
                axis_component,
                radius,
                polar_angle,
                azimuth
            );

        const double magnitude_error =
            fabs(
                actual.magnitude
                - expected_magnitude
            );

        const double magnitude_scale =
            1.0 + expected_magnitude;

        const double phase_error =
            fabs(
                phase_difference(
                    actual.phase,
                    expected_phase
                )
            );

        const int phase_matters =
            expected_magnitude > 1e-14;

        if (
            !isfinite(actual.magnitude)
            || !isfinite(actual.phase)
            || actual.magnitude < 0.0
            || magnitude_error
                > 2e-12 * magnitude_scale
            || (
                phase_matters
                && phase_error > 2e-12
            )
        ) {
            fprintf(
                stderr,
                "FAIL: "
                "state=(%d,%d,%d) "
                "point=(%.17g,%.17g,%.17g) "
                "expected=(magnitude %.17g, phase %.17g) "
                "actual=(magnitude %.17g, phase %.17g) "
                "errors=(%.17g, %.17g)\n",
                energy_level,
                angular_degree,
                axis_component,
                radius,
                polar_angle,
                azimuth,
                expected_magnitude,
                expected_phase,
                actual.magnitude,
                actual.phase,
                magnitude_error,
                phase_error
            );

            fclose(receipts);
            return 1;
        }

        checked += 1;
    }

    fclose(receipts);

    if (checked != 90) {
        fprintf(
            stderr,
            "FAIL: expected 90 polar runtime receipts; got %d\n",
            checked
        );
        return 1;
    }

    printf(
        "PASS: %d polar Complex F64 runtime receipts\n",
        checked
    );

    return 0;
}
