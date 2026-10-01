module pauli_leaf;

extern(C):

float pauli_radial_squared(float x, float y) {
    return x * x + y * y;
}

float pauli_p_shape_squared(float x) {
    return x * x;
}

float pauli_d_shape(float x, float y) {
    return x * y;
}

float pauli_f_shape(float x, float y, float z) {
    return x * y * z;
}

bool pauli_negative(float value) {
    return value < 0.0f;
}

float pauli_clamp_channel(float value) {
    if (value < 0.0f) {
        return 0.0f;
    }
    if (value > 1.0f) {
        return 1.0f;
    }
    return value;
}
