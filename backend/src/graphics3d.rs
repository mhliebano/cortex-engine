use raylib_sys::{
    BeginMode3D, Camera3D, Color, DrawCube, DrawCubeWires, DrawGrid, DrawLine3D, EndMode3D, Vector3,
};
use std::os::raw::{c_int, c_uchar};

pub fn begin_mode(
    cam_x: f32,
    cam_y: f32,
    cam_z: f32,
    target_x: f32,
    target_y: f32,
    target_z: f32,
    up_x: f32,
    up_y: f32,
    up_z: f32,
    fovy: f32,
    projection: c_int,
) {
    let camera = Camera3D {
        position: Vector3 {
            x: cam_x,
            y: cam_y,
            z: cam_z,
        },
        target: Vector3 {
            x: target_x,
            y: target_y,
            z: target_z,
        },
        up: Vector3 {
            x: up_x,
            y: up_y,
            z: up_z,
        },
        fovy,
        projection,
    };
    unsafe { BeginMode3D(camera) }
}

pub fn end_mode() {
    unsafe { EndMode3D() }
}

pub fn draw_grid(slices: c_int, spacing: f32) {
    unsafe { DrawGrid(slices, spacing) }
}

pub fn draw_box(x: f32, y: f32, z: f32, w: f32, h: f32, d: f32, color: Color) {
    unsafe { DrawCube(Vector3 { x, y, z }, w, h, d, color) }
}

pub fn draw_box_wires(x: f32, y: f32, z: f32, w: f32, h: f32, d: f32, color: Color) {
    unsafe { DrawCubeWires(Vector3 { x, y, z }, w, h, d, color) }
}

#[unsafe(no_mangle)]
pub extern "C" fn g3d_begin_mode(
    cam_x: f32,
    cam_y: f32,
    cam_z: f32,
    target_x: f32,
    target_y: f32,
    target_z: f32,
    up_x: f32,
    up_y: f32,
    up_z: f32,
    fovy: f32,
    projection: c_int,
) {
    begin_mode(
        cam_x, cam_y, cam_z, target_x, target_y, target_z, up_x, up_y, up_z, fovy, projection,
    );
}

#[unsafe(no_mangle)]
pub extern "C" fn g3d_end_mode() {
    end_mode();
}

#[unsafe(no_mangle)]
pub extern "C" fn g3d_draw_grid(slices: c_int, spacing: f32) {
    draw_grid(slices, spacing);
}

#[unsafe(no_mangle)]
pub extern "C" fn g3d_draw_box(
    x: f32,
    y: f32,
    z: f32,
    w: f32,
    h: f32,
    d: f32,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    draw_box(x, y, z, w, h, d, Color { r, g, b, a });
}

#[unsafe(no_mangle)]
pub extern "C" fn g3d_draw_box_wires(
    x: f32,
    y: f32,
    z: f32,
    w: f32,
    h: f32,
    d: f32,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    draw_box_wires(x, y, z, w, h, d, Color { r, g, b, a });
}

#[unsafe(no_mangle)]
pub extern "C" fn g3d_draw_line3d(
    start_x: f32,
    start_y: f32,
    start_z: f32,
    end_x: f32,
    end_y: f32,
    end_z: f32,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    unsafe {
        DrawLine3D(
            Vector3 {
                x: start_x,
                y: start_y,
                z: start_z,
            },
            Vector3 {
                x: end_x,
                y: end_y,
                z: end_z,
            },
            Color { r, g, b, a },
        );
    }
}

