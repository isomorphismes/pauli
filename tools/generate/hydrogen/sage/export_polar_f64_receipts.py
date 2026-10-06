#!/usr/bin/env python3

from math import atan2
from pathlib import Path
import sys

from sage.all import ComplexField, QQ

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
    (QQ(3) / 8, QQ(2) / 5, QQ(1) / 4),
    (QQ(9) / 7, QQ(7) / 6, QQ(4) / 3),
    (QQ(19) / 6, QQ(11) / 5, QQ(13) / 5),
]

# Evaluate the symbolic expression above binary64 precision and round only
# the receipt fields. Direct CDF conversion rounded intermediate operations
# and depended on fresh-process symbolic evaluation order.
receipt_complex = ComplexField(200)


def binary64_text(value):
    return format(float(value), ".17g")


for energy_level, angular_degree, axis_component in spdf_states():
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
        value = receipt_complex(
            expression.subs(
                {
                    radius: sample_radius,
                    polar_angle: sample_polar_angle,
                    azimuth: sample_azimuth,
                }
            )
        )

        real_value = float(value.real())
        imaginary_value = float(value.imag())

        print(
            energy_level,
            angular_degree,
            axis_component,
            binary64_text(sample_radius),
            binary64_text(sample_polar_angle),
            binary64_text(sample_azimuth),
            binary64_text(abs(value)),
            binary64_text(
                atan2(
                    imaginary_value,
                    real_value,
                )
            ),
            sep="\t",
        )
