module pauli_android;

private enum int android_log_info = 4;

private enum int ainput_event_type_motion = 2;
private enum int amotion_event_action_mask = 0xff;
private enum int amotion_event_action_down = 0;
private enum int amotion_event_action_up = 1;
private enum int amotion_event_action_move = 2;
private enum int amotion_event_action_cancel = 3;

private enum int app_cmd_init_window = 1;
private enum int app_cmd_term_window = 2;
private enum int app_cmd_window_resized = 3;
private enum int app_cmd_gained_focus = 6;
private enum int app_cmd_config_changed = 8;

private enum uint egl_false = 0;
private enum uint egl_true = 1;
private enum int egl_none = 0x3038;
private enum int egl_surface_type = 0x3033;
private enum int egl_window_bit = 0x0004;
private enum int egl_renderable_type = 0x3040;
private enum int egl_opengl_es2_bit = 0x0004;
private enum int egl_opengl_es3_bit_khr = 0x0040;
private enum int egl_red_size = 0x3024;
private enum int egl_green_size = 0x3023;
private enum int egl_blue_size = 0x3022;
private enum int egl_alpha_size = 0x3021;
private enum int egl_depth_size = 0x3025;
private enum int egl_native_visual_id = 0x302e;
private enum int egl_context_client_version = 0x3098;
private enum uint egl_opengl_es_api = 0x30a0;
private enum int egl_width = 0x3057;
private enum int egl_height = 0x3056;

private struct AndroidApp;
private struct AndroidPollSource;
private struct AInputEvent;
private struct ANativeWindow;

private struct EGLDisplayHandle;
private struct EGLSurfaceHandle;
private struct EGLContextHandle;
private struct EGLConfigHandle;

private alias EGLDisplay = EGLDisplayHandle*;
private alias EGLSurface = EGLSurfaceHandle*;
private alias EGLContext = EGLContextHandle*;
private alias EGLConfig = EGLConfigHandle*;
private alias EGLBoolean = uint;
private alias EGLint = int;

private extern(C) {
    void app_dummy();

    void pauli_android_bridge_attach(
        AndroidApp* app,
        void* user_data,
        void function(AndroidApp*, int) command_callback,
        int function(AndroidApp*, AInputEvent*) input_callback
    );
    void* pauli_android_bridge_user_data(AndroidApp* app);
    ANativeWindow* pauli_android_bridge_window(AndroidApp* app);
    int pauli_android_bridge_destroy_requested(AndroidApp* app);
    void pauli_android_bridge_process_source(
        AndroidApp* app,
        AndroidPollSource* source
    );

    int AInputEvent_getType(const(AInputEvent)* event);
    int AMotionEvent_getAction(const(AInputEvent)* event);
    float AMotionEvent_getX(const(AInputEvent)* event, size_t pointer_index);
    float AMotionEvent_getY(const(AInputEvent)* event, size_t pointer_index);

    int ALooper_pollOnce(
        int timeout_millis,
        int* out_fd,
        int* out_events,
        void** out_data
    );

    int ANativeWindow_setBuffersGeometry(
        ANativeWindow* window,
        int width,
        int height,
        int format
    );

    int __android_log_print(
        int priority,
        const(char)* tag,
        const(char)* format,
        ...
    );

    EGLDisplay eglGetDisplay(void* display_id);
    EGLBoolean eglInitialize(
        EGLDisplay display,
        EGLint* major,
        EGLint* minor
    );
    EGLBoolean eglBindAPI(uint api);
    EGLBoolean eglChooseConfig(
        EGLDisplay display,
        const(EGLint)* attributes,
        EGLConfig* configs,
        EGLint config_size,
        EGLint* count
    );
    EGLBoolean eglGetConfigAttrib(
        EGLDisplay display,
        EGLConfig config,
        EGLint attribute,
        EGLint* value
    );
    EGLContext eglCreateContext(
        EGLDisplay display,
        EGLConfig config,
        EGLContext share_context,
        const(EGLint)* attributes
    );
    EGLSurface eglCreateWindowSurface(
        EGLDisplay display,
        EGLConfig config,
        ANativeWindow* window,
        const(EGLint)* attributes
    );
    EGLBoolean eglMakeCurrent(
        EGLDisplay display,
        EGLSurface draw,
        EGLSurface read,
        EGLContext context
    );
    EGLBoolean eglQuerySurface(
        EGLDisplay display,
        EGLSurface surface,
        EGLint attribute,
        EGLint* value
    );
    EGLBoolean eglSwapBuffers(EGLDisplay display, EGLSurface surface);
    EGLBoolean eglDestroyContext(EGLDisplay display, EGLContext context);
    EGLBoolean eglDestroySurface(EGLDisplay display, EGLSurface surface);
    EGLBoolean eglTerminate(EGLDisplay display);

    int pauli_renderer_start(int width, int height, int gles_major);
    void pauli_renderer_resize(int width, int height);
    void pauli_renderer_drag(float delta_x, float delta_y);
    void pauli_renderer_cycle_orbital();
    void pauli_renderer_draw();
    void pauli_renderer_stop();

    float fabsf(float value);
}

private struct PauliAndroidState {
    AndroidApp* app = null;

    EGLDisplay display = null;
    EGLSurface surface = null;
    EGLContext context = null;

    int gles_major = 0;
    int width = 0;
    int height = 0;

    bool renderer_started = false;
    bool redraw = false;
    bool touching = false;
    bool moved = false;

    float previous_x = 0.0f;
    float previous_y = 0.0f;
}

private immutable(char)[] log_tag = "PauliNative";

private void log_native_entry() {
    __android_log_print(
        android_log_info,
        log_tag.ptr,
        "native entry".ptr
    );
}

private void log_surface_ready(int width, int height, int gles_major) {
    __android_log_print(
        android_log_info,
        log_tag.ptr,
        "EGL surface ready: %d×%d GLES %d".ptr,
        width,
        height,
        gles_major
    );
}

private void log_drag(float delta_x, float delta_y) {
    __android_log_print(
        android_log_info,
        log_tag.ptr,
        "drag: %.6f %.6f".ptr,
        cast(double) delta_x,
        cast(double) delta_y
    );
}

private void log_tap() {
    __android_log_print(
        android_log_info,
        log_tag.ptr,
        "tap: cycle orbital".ptr
    );
}

private void log_frame_presented() {
    __android_log_print(
        android_log_info,
        log_tag.ptr,
        "frame presented".ptr
    );
}

private void pauli_stop_surface(PauliAndroidState* state) {
    if (state.renderer_started) {
        pauli_renderer_stop();
        state.renderer_started = false;
    }

    if (state.display !is null) {
        eglMakeCurrent(state.display, null, null, null);

        if (state.context !is null) {
            eglDestroyContext(state.display, state.context);
        }
        if (state.surface !is null) {
            eglDestroySurface(state.display, state.surface);
        }

        eglTerminate(state.display);
    }

    state.display = null;
    state.surface = null;
    state.context = null;
    state.gles_major = 0;
    state.width = 0;
    state.height = 0;
    state.redraw = false;
}

private bool pauli_choose_config(
    EGLDisplay display,
    int gles_major,
    out EGLConfig config
) {
    const renderable =
        gles_major >= 3 ? egl_opengl_es3_bit_khr : egl_opengl_es2_bit;

    const EGLint[15] attributes = [
        egl_surface_type, egl_window_bit,
        egl_renderable_type, renderable,
        egl_red_size, 8,
        egl_green_size, 8,
        egl_blue_size, 8,
        egl_alpha_size, 8,
        egl_depth_size, 16,
        egl_none
    ];

    EGLint count = 0;
    return
        eglChooseConfig(
            display,
            attributes.ptr,
            &config,
            1,
            &count
        ) == egl_true &&
        count == 1;
}

private bool pauli_start_surface(PauliAndroidState* state) {
    auto window = pauli_android_bridge_window(state.app);
    if (window is null) {
        return false;
    }

    pauli_stop_surface(state);

    state.display = eglGetDisplay(null);
    if (state.display is null) {
        return false;
    }

    if (eglInitialize(state.display, null, null) != egl_true) {
        pauli_stop_surface(state);
        return false;
    }

    if (eglBindAPI(egl_opengl_es_api) != egl_true) {
        pauli_stop_surface(state);
        return false;
    }

    EGLConfig config = null;
    int gles_major = 3;

    if (!pauli_choose_config(state.display, gles_major, config)) {
        gles_major = 2;
        if (!pauli_choose_config(state.display, gles_major, config)) {
            pauli_stop_surface(state);
            return false;
        }
    }

    EGLint native_format = 0;
    if (
        eglGetConfigAttrib(
            state.display,
            config,
            egl_native_visual_id,
            &native_format
        ) != egl_true
    ) {
        pauli_stop_surface(state);
        return false;
    }

    ANativeWindow_setBuffersGeometry(window, 0, 0, native_format);

    const EGLint[3] context_attributes = [
        egl_context_client_version,
        gles_major,
        egl_none
    ];

    state.context = eglCreateContext(
        state.display,
        config,
        null,
        context_attributes.ptr
    );
    if (state.context is null) {
        pauli_stop_surface(state);
        return false;
    }

    state.surface = eglCreateWindowSurface(
        state.display,
        config,
        window,
        null
    );
    if (state.surface is null) {
        pauli_stop_surface(state);
        return false;
    }

    if (
        eglMakeCurrent(
            state.display,
            state.surface,
            state.surface,
            state.context
        ) != egl_true
    ) {
        pauli_stop_surface(state);
        return false;
    }

    EGLint width = 0;
    EGLint height = 0;
    eglQuerySurface(state.display, state.surface, egl_width, &width);
    eglQuerySurface(state.display, state.surface, egl_height, &height);

    state.gles_major = gles_major;
    state.width = width;
    state.height = height;

    if (!pauli_renderer_start(width, height, gles_major)) {
        pauli_stop_surface(state);
        return false;
    }

    state.renderer_started = true;
    state.redraw = true;
    log_surface_ready(width, height, gles_major);
    return true;
}

private void pauli_resize(PauliAndroidState* state) {
    if (!state.renderer_started || state.surface is null) {
        return;
    }

    EGLint width = 0;
    EGLint height = 0;
    eglQuerySurface(state.display, state.surface, egl_width, &width);
    eglQuerySurface(state.display, state.surface, egl_height, &height);

    if (width > 0 && height > 0) {
        state.width = width;
        state.height = height;
        pauli_renderer_resize(width, height);
        state.redraw = true;
    }
}

private extern(C) void pauli_handle_command(
    AndroidApp* app,
    int command
) {
    auto state = cast(PauliAndroidState*)
        pauli_android_bridge_user_data(app);

    switch (command) {
        case app_cmd_init_window:
            pauli_start_surface(state);
            break;

        case app_cmd_term_window:
            pauli_stop_surface(state);
            break;

        case app_cmd_window_resized:
        case app_cmd_config_changed:
            pauli_resize(state);
            break;

        case app_cmd_gained_focus:
            state.redraw = true;
            break;

        default:
            break;
    }
}

private extern(C) int pauli_handle_input(
    AndroidApp* app,
    AInputEvent* event
) {
    auto state = cast(PauliAndroidState*)
        pauli_android_bridge_user_data(app);

    if (AInputEvent_getType(event) != ainput_event_type_motion) {
        return 0;
    }

    const action =
        AMotionEvent_getAction(event) & amotion_event_action_mask;
    const x = AMotionEvent_getX(event, 0);
    const y = AMotionEvent_getY(event, 0);

    if (action == amotion_event_action_down) {
        state.touching = true;
        state.moved = false;
        state.previous_x = x;
        state.previous_y = y;
        return 1;
    }

    if (action == amotion_event_action_move && state.touching) {
        int short_side_pixels = 1;
        if (state.width > 0 && state.height > 0) {
            short_side_pixels =
                state.width < state.height ? state.width : state.height;
        }

        const short_side = cast(float) short_side_pixels;
        const delta_x = (x - state.previous_x) / short_side;
        const delta_y = (y - state.previous_y) / short_side;

        if (fabsf(delta_x) + fabsf(delta_y) > 0.001f) {
            state.moved = true;
            pauli_renderer_drag(delta_x, delta_y);
            log_drag(delta_x, delta_y);
            state.redraw = true;
        }

        state.previous_x = x;
        state.previous_y = y;
        return 1;
    }

    if (
        (action == amotion_event_action_up ||
         action == amotion_event_action_cancel) &&
        state.touching
    ) {
        if (action == amotion_event_action_up && !state.moved) {
            pauli_renderer_cycle_orbital();
            log_tap();
            state.redraw = true;
        }

        state.touching = false;
        state.moved = false;
        return 1;
    }

    return 0;
}

extern(C) void android_main(AndroidApp* app) {
    app_dummy();
    log_native_entry();

    PauliAndroidState state;
    state.app = app;

    pauli_android_bridge_attach(
        app,
        &state,
        &pauli_handle_command,
        &pauli_handle_input
    );

    for (;;) {
        int events = 0;
        AndroidPollSource* source = null;

        const timeout =
            state.renderer_started && state.redraw ? 0 : -1;

        int ident = 0;
        while (
            (ident = ALooper_pollOnce(
                timeout,
                null,
                &events,
                cast(void**) &source
            )) >= 0
        ) {
            if (source !is null) {
                pauli_android_bridge_process_source(app, source);
            }

            if (pauli_android_bridge_destroy_requested(app) != 0) {
                pauli_stop_surface(&state);
                return;
            }

            if (state.renderer_started && state.redraw) {
                break;
            }
        }

        if (pauli_android_bridge_destroy_requested(app) != 0) {
            pauli_stop_surface(&state);
            return;
        }

        if (state.renderer_started && state.redraw) {
            pauli_renderer_draw();

            if (
                eglSwapBuffers(state.display, state.surface) != egl_true
            ) {
                pauli_stop_surface(&state);
                continue;
            }

            log_frame_presented();
            state.redraw = false;
        }
    }
}
