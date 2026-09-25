#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include "hydrogen_spdf_f64.h"

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
    double expected_real;
    double expected_imaginary;
    int checked = 0;

    if (argc != 2) {
        fprintf(
            stderr,
            "usage: %s f64_receipts.tsv\n",
            argv[0]
        );
        return 2;
    }

    receipts = fopen(
        argv[1],
        "r"
    );

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
            &expected_real,
            &expected_imaginary
        ) == 8
    ) {
        pauli_complex_f64 actual =
            pauli_hydrogen_spdf_f64(
                energy_level,
                angular_degree,
                axis_component,
                radius,
                polar_angle,
                azimuth
            );

        double error = hypot(
            actual.real
                - expected_real,
            actual.imaginary
                - expected_imaginary
        );

        double scale =
            1.0
            + hypot(
                expected_real,
                expected_imaginary
            );

        if (
            !isfinite(actual.real)
            || !isfinite(actual.imaginary)
            || error > 2e-12 * scale
        ) {
            fprintf(
                stderr,
                "FAIL: "
                "state=(%d,%d,%d) "
                "point=(%.17g,%.17g,%.17g) "
                "expected=(%.17g,%.17g) "
                "actual=(%.17g,%.17g) "
                "error=%.17g\n",
                energy_level,
                angular_degree,
                axis_component,
                radius,
                polar_angle,
                azimuth,
                expected_real,
                expected_imaginary,
                actual.real,
                actual.imaginary,
                error
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
            "FAIL: expected 90 runtime receipts; got %d\n",
            checked
        );
        return 1;
    }

    printf(
        "PASS: %d Complex F64 runtime receipts\n",
        checked
    );

    return 0;
}
