use raylib_sys::{
    BeginDrawing, BeginScissorMode, ClearBackground, Color, EndDrawing, EndScissorMode,
};
use std::os::raw::c_uchar;

pub fn begin_frame(r: c_uchar, g: c_uchar, b: c_uchar, a: c_uchar) {
    unsafe {
        BeginDrawing();
        ClearBackground(Color { r, g, b, a });
    }
}

pub fn end_frame() {
    unsafe {
        EndDrawing();
    }
}

pub fn begin_scissor(x: i32, y: i32, width: i32, height: i32) {
    unsafe {
        BeginScissorMode(x, y, width, height);
    }
}

pub fn end_scissor() {
    unsafe {
        EndScissorMode();
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn renderer_begin_frame(r: c_uchar, g: c_uchar, b: c_uchar, a: c_uchar) {
    begin_frame(r, g, b, a);
}

#[unsafe(no_mangle)]
pub extern "C" fn renderer_end_frame() {
    end_frame();
}

#[unsafe(no_mangle)]
pub extern "C" fn renderer_begin_scissor(x: i32, y: i32, width: i32, height: i32) {
    begin_scissor(x, y, width, height);
}

#[unsafe(no_mangle)]
pub extern "C" fn renderer_end_scissor() {
    end_scissor();
}
