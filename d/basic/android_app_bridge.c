#include <android/input.h>
#include <android/native_window.h>
#include <android_native_app_glue.h>

#include <stdint.h>

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
