use raylib_sys::{
    GetCharPressed, GetClipboardText, GetFrameTime, GetMousePosition, GetMouseWheelMove, GetTime,
    IsKeyDown, IsKeyPressed, IsMouseButtonDown, IsMouseButtonPressed, IsMouseButtonReleased,
    SetClipboardText,
};
use std::os::raw::{c_char, c_int};

#[unsafe(no_mangle)]
pub extern "C" fn input_get_mouse_x() -> f32 {
    unsafe { GetMousePosition().x }
}

#[unsafe(no_mangle)]
pub extern "C" fn input_get_mouse_y() -> f32 {
    unsafe { GetMousePosition().y }
}

#[unsafe(no_mangle)]
pub extern "C" fn input_is_mouse_button_pressed(button: c_int) -> i32 {
    if unsafe { IsMouseButtonPressed(button) } {
        1
    } else {
        0
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn input_is_mouse_button_down(button: c_int) -> i32 {
    if unsafe { IsMouseButtonDown(button) } {
        1
    } else {
        0
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn input_is_mouse_button_released(button: c_int) -> i32 {
    if unsafe { IsMouseButtonReleased(button) } {
        1
    } else {
        0
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn input_get_mouse_wheel_move() -> f32 {
    unsafe { GetMouseWheelMove() }
}

#[unsafe(no_mangle)]
pub extern "C" fn input_is_key_pressed(key: c_int) -> i32 {
    if unsafe { IsKeyPressed(key) } {
        1
    } else {
        0
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn input_is_key_down(key: c_int) -> i32 {
    if unsafe { IsKeyDown(key) } {
        1
    } else {
        0
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn input_get_char_pressed() -> c_int {
    unsafe { GetCharPressed() }
}

#[unsafe(no_mangle)]
pub extern "C" fn input_get_frame_time() -> f32 {
    unsafe { GetFrameTime() }
}

#[unsafe(no_mangle)]
pub extern "C" fn input_get_time() -> f64 {
    unsafe { GetTime() }
}

#[unsafe(no_mangle)]
pub extern "C" fn input_set_clipboard_text(text: *const c_char) {
    if !text.is_null() {
        unsafe { SetClipboardText(text) };
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn input_get_clipboard_text() -> *const c_char {
    unsafe { GetClipboardText() }
}
