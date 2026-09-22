use raylib_sys::{
    ClearWindowState, CloseWindow, GetScreenHeight, GetScreenWidth, InitWindow, IsWindowFocused,
    IsWindowMinimized, IsWindowResized, MaximizeWindow, MinimizeWindow, RestoreWindow,
    SetConfigFlags, SetTargetFPS, SetWindowMinSize, SetWindowPosition, SetWindowState,
    ToggleFullscreen, WindowShouldClose,
};
use std::os::raw::{c_char, c_int, c_uint};

static SAVED_CONFIG_FLAGS: std::sync::atomic::AtomicU32 = std::sync::atomic::AtomicU32::new(0);

pub mod flags {
    pub const VSYNC_HINT: u32 = 64;
    pub const FULLSCREEN_MODE: u32 = 2;
    pub const WINDOW_RESIZABLE: u32 = 4;
    pub const WINDOW_UNDECORATED: u32 = 8;
    pub const WINDOW_HIDDEN: u32 = 128;
    pub const WINDOW_MINIMIZED: u32 = 512;
    pub const WINDOW_MAXIMIZED: u32 = 1024;
    pub const WINDOW_UNFOCUSED: u32 = 2048;
    pub const WINDOW_TOPMOST: u32 = 4096;
    pub const WINDOW_ALWAYS_RUN: u32 = 256;
    pub const WINDOW_TRANSPARENT: u32 = 16;
    pub const WINDOW_HIGHDPI: u32 = 8192;
    pub const WINDOW_MOUSE_PASSTHROUGH: u32 = 16384;
    pub const WINDOW_SKIP_TASKBAR: u32 = 1048576;
}

pub fn set_config_flags(flags: c_uint) {
    SAVED_CONFIG_FLAGS.store(flags, std::sync::atomic::Ordering::SeqCst);
    // Filtrar banderas personalizadas para no interferir con las banderas nativas de Raylib
    let raylib_flags = flags & !flags::WINDOW_SKIP_TASKBAR;
    unsafe { SetConfigFlags(raylib_flags) }
}
pub fn init(width: c_int, height: c_int, title: *const c_char) {
    unsafe { 
        InitWindow(width, height, title);
    }
    let flags = SAVED_CONFIG_FLAGS.load(std::sync::atomic::Ordering::SeqCst);
    if (flags & flags::WINDOW_SKIP_TASKBAR) != 0 {
        apply_skip_taskbar();
    }
}

#[cfg(target_os = "linux")]
fn apply_skip_taskbar() {
    use std::ffi::CString;
    type Display = std::ffi::c_void;
    type XID = std::ffi::c_ulong;
    type Window = XID;
    type Atom = XID;

    #[repr(C)]
    struct XClientMessageEvent {
        type_: std::ffi::c_int,
        serial: std::ffi::c_ulong,
        send_event: std::ffi::c_int,
        display: *mut Display,
        window: Window,
        message_type: Atom,
        format: std::ffi::c_int,
        l: [std::ffi::c_long; 5],
    }

    unsafe {
        let handle = raylib_sys::GetWindowHandle();
        if handle.is_null() {
            return;
        }
        let window_xid: Window = *(handle as *const Window);
        if window_xid == 0 {
            return;
        }

        let x11_lib = CString::new("libX11.so.6").unwrap();
        let lib = libc::dlopen(x11_lib.as_ptr(), libc::RTLD_LAZY);
        let lib = if lib.is_null() {
            let x11_lib_alt = CString::new("libX11.so").unwrap();
            libc::dlopen(x11_lib_alt.as_ptr(), libc::RTLD_LAZY)
        } else {
            lib
        };

        if lib.is_null() {
            return;
        }

        type FnXOpenDisplay = unsafe extern "C" fn(*const std::ffi::c_char) -> *mut Display;
        type FnXDefaultRootWindow = unsafe extern "C" fn(*mut Display) -> Window;
        type FnXInternAtom = unsafe extern "C" fn(*mut Display, *const std::ffi::c_char, std::ffi::c_int) -> Atom;
        type FnXChangeProperty = unsafe extern "C" fn(
            *mut Display,
            Window,
            Atom,
            Atom,
            std::ffi::c_int,
            std::ffi::c_int,
            *const u8,
            std::ffi::c_int,
        ) -> std::ffi::c_int;
        type FnXSendEvent = unsafe extern "C" fn(
            *mut Display,
            Window,
            std::ffi::c_int,
            std::ffi::c_long,
            *mut XClientMessageEvent,
        ) -> std::ffi::c_int;
        type FnXSetTransientForHint = unsafe extern "C" fn(*mut Display, Window, Window) -> std::ffi::c_int;
        type FnXFlush = unsafe extern "C" fn(*mut Display) -> std::ffi::c_int;
        type FnXCloseDisplay = unsafe extern "C" fn(*mut Display) -> std::ffi::c_int;

        let fn_open_display: Option<FnXOpenDisplay> =
            std::mem::transmute(libc::dlsym(lib, CString::new("XOpenDisplay").unwrap().as_ptr()));
        let fn_default_root: Option<FnXDefaultRootWindow> =
            std::mem::transmute(libc::dlsym(lib, CString::new("XDefaultRootWindow").unwrap().as_ptr()));
        let fn_intern_atom: Option<FnXInternAtom> =
            std::mem::transmute(libc::dlsym(lib, CString::new("XInternAtom").unwrap().as_ptr()));
        let fn_change_property: Option<FnXChangeProperty> =
            std::mem::transmute(libc::dlsym(lib, CString::new("XChangeProperty").unwrap().as_ptr()));
        let fn_send_event: Option<FnXSendEvent> =
            std::mem::transmute(libc::dlsym(lib, CString::new("XSendEvent").unwrap().as_ptr()));
        let fn_set_transient: Option<FnXSetTransientForHint> =
            std::mem::transmute(libc::dlsym(lib, CString::new("XSetTransientForHint").unwrap().as_ptr()));
        let fn_flush: Option<FnXFlush> =
            std::mem::transmute(libc::dlsym(lib, CString::new("XFlush").unwrap().as_ptr()));
        let fn_close_display: Option<FnXCloseDisplay> =
            std::mem::transmute(libc::dlsym(lib, CString::new("XCloseDisplay").unwrap().as_ptr()));

        if let (
            Some(x_open_display),
            Some(x_default_root),
            Some(x_intern_atom),
            Some(x_change_property),
            Some(x_send_event),
            Some(x_flush),
            Some(x_close_display),
        ) = (
            fn_open_display,
            fn_default_root,
            fn_intern_atom,
            fn_change_property,
            fn_send_event,
            fn_flush,
            fn_close_display,
        ) {
            let display = x_open_display(std::ptr::null());
            if !display.is_null() {
                let root = x_default_root(display);

                let net_wm_state = x_intern_atom(display, CString::new("_NET_WM_STATE").unwrap().as_ptr(), 0);
                let skip_taskbar = x_intern_atom(display, CString::new("_NET_WM_STATE_SKIP_TASKBAR").unwrap().as_ptr(), 0);
                let skip_pager = x_intern_atom(display, CString::new("_NET_WM_STATE_SKIP_PAGHER").unwrap().as_ptr(), 0);
                let skip_pager_std = x_intern_atom(display, CString::new("_NET_WM_STATE_SKIP_PAGER").unwrap().as_ptr(), 0);

                let net_wm_window_type = x_intern_atom(display, CString::new("_NET_WM_WINDOW_TYPE").unwrap().as_ptr(), 0);
                let net_wm_window_type_utility = x_intern_atom(display, CString::new("_NET_WM_WINDOW_TYPE_UTILITY").unwrap().as_ptr(), 0);

                const XA_ATOM: Atom = 4;
                const PROP_MODE_REPLACE: std::ffi::c_int = 0;
                const PROP_MODE_APPEND: std::ffi::c_int = 2;

                // 1. Configurar tipo de ventana a UTILITY (Widget de escritorio)
                if net_wm_window_type != 0 && net_wm_window_type_utility != 0 {
                    x_change_property(
                        display,
                        window_xid,
                        net_wm_window_type,
                        XA_ATOM,
                        32,
                        PROP_MODE_REPLACE,
                        (&net_wm_window_type_utility as *const Atom) as *const u8,
                        1,
                    );
                }

                // 2. Establecer propiedades _NET_WM_STATE
                if net_wm_state != 0 && skip_taskbar != 0 {
                    x_change_property(
                        display,
                        window_xid,
                        net_wm_state,
                        XA_ATOM,
                        32,
                        PROP_MODE_APPEND,
                        (&skip_taskbar as *const Atom) as *const u8,
                        1,
                    );
                }

                if net_wm_state != 0 && skip_pager != 0 {
                    x_change_property(
                        display,
                        window_xid,
                        net_wm_state,
                        XA_ATOM,
                        32,
                        PROP_MODE_APPEND,
                        (&skip_pager as *const Atom) as *const u8,
                        1,
                    );
                }

                if net_wm_state != 0 && skip_pager_std != 0 && skip_pager_std != skip_pager {
                    x_change_property(
                        display,
                        window_xid,
                        net_wm_state,
                        XA_ATOM,
                        32,
                        PROP_MODE_APPEND,
                        (&skip_pager_std as *const Atom) as *const u8,
                        1,
                    );
                }

                // 3. Transient hint para Root window
                if let Some(set_transient) = fn_set_transient {
                    if root != 0 {
                        set_transient(display, window_xid, root);
                    }
                }

                // 4. Enviar eventos ClientMessage al Root Window (EWMH Protocol)
                const CLIENT_MESSAGE: std::ffi::c_int = 33;
                const SUBSTRUCTURE_REDIRECT_MASK: std::ffi::c_long = 0x00080000;
                const SUBSTRUCTURE_NOTIFY_MASK: std::ffi::c_long = 0x00040000;
                let event_mask = SUBSTRUCTURE_REDIRECT_MASK | SUBSTRUCTURE_NOTIFY_MASK;

                if net_wm_state != 0 && skip_taskbar != 0 {
                    let mut ev = XClientMessageEvent {
                        type_: CLIENT_MESSAGE,
                        serial: 0,
                        send_event: 0,
                        display,
                        window: window_xid,
                        message_type: net_wm_state,
                        format: 32,
                        l: [1 /* _NET_WM_STATE_ADD */, skip_taskbar as std::ffi::c_long, skip_pager_std as std::ffi::c_long, 1, 0],
                    };
                    x_send_event(display, root, 0, event_mask, &mut ev);
                }

                x_flush(display);
                x_close_display(display);
            }
        }

        libc::dlclose(lib);
    }
}

#[cfg(target_os = "windows")]
fn apply_skip_taskbar() {
    type HWND = *mut std::ffi::c_void;
    type LONG_PTR = isize;

    const GWL_EXSTYLE: i32 = -20;
    const WS_EX_TOOLWINDOW: LONG_PTR = 0x00000080;
    const WS_EX_APPWINDOW: LONG_PTR = 0x00040000;

    unsafe {
        let hwnd = raylib_sys::GetWindowHandle() as HWND;
        if hwnd.is_null() {
            return;
        }

        let user32 = std::ffi::CString::new("user32.dll").unwrap();
        let lib = libc::dlopen(user32.as_ptr(), libc::RTLD_LAZY);
        if lib.is_null() {
            return;
        }

        #[cfg(target_pointer_width = "64")]
        let func_name = "SetWindowLongPtrA";
        #[cfg(not(target_pointer_width = "64"))]
        let func_name = "SetWindowLongA";

        #[cfg(target_pointer_width = "64")]
        let get_func_name = "GetWindowLongPtrA";
        #[cfg(not(target_pointer_width = "64"))]
        let get_func_name = "GetWindowLongA";

        type FnGetWindowLong = unsafe extern "system" fn(HWND, i32) -> LONG_PTR;
        type FnSetWindowLong = unsafe extern "system" fn(HWND, i32, LONG_PTR) -> LONG_PTR;

        let fn_get: Option<FnGetWindowLong> =
            std::mem::transmute(libc::dlsym(lib, std::ffi::CString::new(get_func_name).unwrap().as_ptr()));
        let fn_set: Option<FnSetWindowLong> =
            std::mem::transmute(libc::dlsym(lib, std::ffi::CString::new(func_name).unwrap().as_ptr()));

        if let (Some(get_long), Some(set_long)) = (fn_get, fn_set) {
            let mut style = get_long(hwnd, GWL_EXSTYLE);
            style |= WS_EX_TOOLWINDOW;
            style &= !WS_EX_APPWINDOW;
            set_long(hwnd, GWL_EXSTYLE, style);
        }

        libc::dlclose(lib);
    }
}

#[cfg(not(any(target_os = "linux", target_os = "windows")))]
fn apply_skip_taskbar() {}
pub fn should_close() -> bool {
    unsafe { WindowShouldClose() }
}
pub fn close() {
    unsafe { CloseWindow() }
}

pub fn toggle_fullscreen() {
    unsafe { ToggleFullscreen() }
}
pub fn maximize() {
    unsafe { MaximizeWindow() }
}
pub fn minimize() {
    unsafe { MinimizeWindow() }
}
pub fn restore() {
    unsafe { RestoreWindow() }
}

pub fn set_state(flags: c_uint) {
    unsafe { SetWindowState(flags) }
}
pub fn clear_state(flags: c_uint) {
    unsafe { ClearWindowState(flags) }
}

pub fn is_resized() -> bool {
    unsafe { IsWindowResized() }
}
pub fn is_focused() -> bool {
    unsafe { IsWindowFocused() }
}
pub fn is_minimized() -> bool {
    unsafe { IsWindowMinimized() }
}

pub fn get_width() -> c_int {
    unsafe { GetScreenWidth() }
}
pub fn get_height() -> c_int {
    unsafe { GetScreenHeight() }
}
pub fn get_position_x() -> c_int {
    unsafe { raylib_sys::GetWindowPosition().x as c_int }
}
pub fn get_position_y() -> c_int {
    unsafe { raylib_sys::GetWindowPosition().y as c_int }
}
pub fn set_position(x: c_int, y: c_int) {
    unsafe { SetWindowPosition(x, y) }
}
pub fn set_min_size(width: c_int, height: c_int) {
    unsafe { SetWindowMinSize(width, height) }
}

// API Publica para FFI

#[unsafe(no_mangle)]
pub extern "C" fn window_set_config_flags(flags: u32) {
    set_config_flags(flags);
}
#[unsafe(no_mangle)]
pub extern "C" fn window_init(w: i32, h: i32, t: *const std::os::raw::c_char) {
    init(w, h, t);
}
#[unsafe(no_mangle)]
pub extern "C" fn window_should_close() -> i32 {
    if should_close() { 1 } else { 0 }
}
#[unsafe(no_mangle)]
pub extern "C" fn window_close() {
    close();
}
#[unsafe(no_mangle)]
pub extern "C" fn window_toggle_fullscreen() {
    toggle_fullscreen();
}
#[unsafe(no_mangle)]
pub extern "C" fn window_maximize() {
    maximize();
}
#[unsafe(no_mangle)]
pub extern "C" fn window_minimize() {
    minimize();
}
#[unsafe(no_mangle)]
pub extern "C" fn window_restore() {
    restore();
}
#[unsafe(no_mangle)]
pub extern "C" fn window_set_state(flags: u32) {
    set_state(flags);
}
#[unsafe(no_mangle)]
pub extern "C" fn window_clear_state(flags: u32) {
    clear_state(flags);
}
#[unsafe(no_mangle)]
pub extern "C" fn window_is_resized() -> i32 {
    if is_resized() { 1 } else { 0 }
}
#[unsafe(no_mangle)]
pub extern "C" fn window_is_focused() -> i32 {
    if is_focused() { 1 } else { 0 }
}
#[unsafe(no_mangle)]
pub extern "C" fn window_is_minimized() -> i32 {
    if is_minimized() { 1 } else { 0 }
}
#[unsafe(no_mangle)]
pub extern "C" fn window_get_width() -> i32 {
    get_width()
}
#[unsafe(no_mangle)]
pub extern "C" fn window_get_height() -> i32 {
    get_height()
}
#[unsafe(no_mangle)]
pub extern "C" fn window_get_position_x() -> i32 {
    get_position_x()
}
#[unsafe(no_mangle)]
pub extern "C" fn window_get_position_y() -> i32 {
    get_position_y()
}
#[unsafe(no_mangle)]
pub extern "C" fn window_set_position(x: i32, y: i32) {
    set_position(x, y);
}
#[unsafe(no_mangle)]
pub extern "C" fn window_set_min_size(w: i32, h: i32) {
    set_min_size(w, h);
}

/// Establece el límite de FPS objetivo del bucle de Raylib.
/// Pasar 0 elimina el límite (corre tan rápido como sea posible).
/// Usado por el modo FPS adaptativo de `Application` para reducir el
/// consumo de CPU/batería cuando la ventana está inactiva.
#[unsafe(no_mangle)]
pub extern "C" fn window_set_target_fps(fps: i32) {
    unsafe { SetTargetFPS(fps) }
}
