#include <android/input.h>
#include <android/native_window.h>
#include <android_native_app_glue.h>
#include <EGL/egl.h>
#include <EGL/eglext.h>

#include <stdint.h>

_Static_assert(AINPUT_EVENT_TYPE_MOTION == 2, "D input type constant drift");
_Static_assert(AMOTION_EVENT_ACTION_MASK == 0xff, "D action mask drift");
_Static_assert(AMOTION_EVENT_ACTION_DOWN == 0, "D DOWN constant drift");
_Static_assert(AMOTION_EVENT_ACTION_UP == 1, "D UP constant drift");
_Static_assert(AMOTION_EVENT_ACTION_MOVE == 2, "D MOVE constant drift");
_Static_assert(AMOTION_EVENT_ACTION_CANCEL == 3, "D CANCEL constant drift");

_Static_assert(APP_CMD_INIT_WINDOW == 1, "D INIT_WINDOW constant drift");
_Static_assert(APP_CMD_TERM_WINDOW == 2, "D TERM_WINDOW constant drift");
_Static_assert(APP_CMD_WINDOW_RESIZED == 3, "D WINDOW_RESIZED constant drift");
_Static_assert(APP_CMD_GAINED_FOCUS == 6, "D GAINED_FOCUS constant drift");
_Static_assert(APP_CMD_CONFIG_CHANGED == 8, "D CONFIG_CHANGED constant drift");

_Static_assert(EGL_NONE == 0x3038, "D EGL_NONE constant drift");
_Static_assert(EGL_SURFACE_TYPE == 0x3033, "D EGL_SURFACE_TYPE constant drift");
_Static_assert(EGL_WINDOW_BIT == 0x0004, "D EGL_WINDOW_BIT constant drift");
_Static_assert(EGL_RENDERABLE_TYPE == 0x3040, "D EGL_RENDERABLE_TYPE drift");
_Static_assert(EGL_OPENGL_ES2_BIT == 0x0004, "D GLES2 bit drift");
_Static_assert(EGL_OPENGL_ES3_BIT_KHR == 0x0040, "D GLES3 bit drift");
_Static_assert(EGL_NATIVE_VISUAL_ID == 0x302e, "D native visual drift");
_Static_assert(EGL_CONTEXT_CLIENT_VERSION == 0x3098, "D context version drift");
_Static_assert(EGL_OPENGL_ES_API == 0x30a0, "D GLES API constant drift");
_Static_assert(EGL_WIDTH == 0x3057, "D EGL_WIDTH constant drift");
_Static_assert(EGL_HEIGHT == 0x3056, "D EGL_HEIGHT constant drift");

/*
 * android_app and android_poll_source are NDK glue structs, not Pauli data.
 * Keep their concrete layout on the C side so the D application code can
 * treat them as opaque ABI handles.
 */

void pauli_android_bridge_attach(
    struct android_app *app,
    void *user_data,
    void (*command_callback)(struct android_app *, int32_t),
    int32_t (*input_callback)(struct android_app *, AInputEvent *)
) {
    app->userData = user_data;
    app->onAppCmd = command_callback;
    app->onInputEvent = input_callback;
}

void *pauli_android_bridge_user_data(struct android_app *app) {
    return app->userData;
}

ANativeWindow *pauli_android_bridge_window(struct android_app *app) {
    return app->window;
}

int pauli_android_bridge_destroy_requested(struct android_app *app) {
    return app->destroyRequested;
}

void pauli_android_bridge_process_source(
    struct android_app *app,
    struct android_poll_source *source
) {
    source->process(app, source);
}
