#!/usr/bin/env python3

from pathlib import Path
import sys

from sage.all import CDF, QQ

sys.path.insert(
    0,
    str(Path(__file__).resolve().parent),
)

from hydrogen_states import (
    azimuth,
    bound_state,
    polar_angle,
    radius,
    spdf_states,
)

sample_points = [
    (
        QQ(3) / 8,
        QQ(2) / 5,
        QQ(1) / 4,
    ),
    (
        QQ(9) / 7,
        QQ(7) / 6,
        QQ(4) / 3,
    ),
    (
        QQ(19) / 6,
        QQ(11) / 5,
        QQ(13) / 5,
    ),
]


def binary64_text(value):
    return format(
        float(value),
        ".17g",
    )


for (
    energy_level,
    angular_degree,
    axis_component,
) in spdf_states():
    expression = bound_state(
        energy_level,
        angular_degree,
        axis_component,
    )

    for (
        sample_radius,
        sample_polar_angle,
        sample_azimuth,
    ) in sample_points:
        value = CDF(
            expression.subs(
                {
                    radius:
                        sample_radius,
                    polar_angle:
                        sample_polar_angle,
                    azimuth:
                        sample_azimuth,
                }
            )
        )

        print(
            energy_level,
            angular_degree,
            axis_component,
            binary64_text(
                sample_radius,
            ),
            binary64_text(
                sample_polar_angle,
            ),
            binary64_text(
                sample_azimuth,
            ),
            binary64_text(
                value.real(),
            ),
            binary64_text(
                value.imag(),
            ),
            sep="\t",
        )
