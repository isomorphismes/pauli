#ifndef PAULI_RENDERER_H
#define PAULI_RENDERER_H

/*
 * Android owns EGL and calls this interface only while its EGL context is
 * current. The renderer owns all Pauli-specific graphics and orbital state.
 *
 * The API deliberately contains no Activity, JNI, ANativeWindow, or DEX types.
 */

#ifdef __cplusplus
extern "C" {
#endif

int pauli_renderer_start(int width, int height, int gles_major);

void pauli_renderer_resize(int width, int height);

/*
 * Normalized screen drag. A full short-screen dimension is approximately one
 * unit. The renderer decides the exact rotation representation.
 */
void pauli_renderer_drag(float delta_x, float delta_y);

/* Minimal viewer gesture: move through a built-in s/p/d/f demonstration set. */
void pauli_renderer_cycle_orbital(void);

/* Draw one frame into the current EGL draw surface. */
void pauli_renderer_draw(void);

void pauli_renderer_stop(void);

#ifdef __cplusplus
}
#endif

#endif
