use raylib_sys::{
    Color, DrawCircle, DrawCircleLines, DrawCircleSector, DrawCircleSectorLines, DrawPoly,
    DrawPolyLinesEx, DrawRectangle, DrawRectangleLines, DrawRectangleRounded,
    DrawRectangleRoundedLinesEx, DrawText, DrawTextEx, DrawTexturePro, DrawTriangle,
    DrawTriangleLines, Font, LoadFontEx, LoadTexture, Rectangle, SetTextureFilter, Texture2D,
    UnloadFont, UnloadTexture, Vector2,
};
use std::collections::HashMap;
use std::os::raw::{c_char, c_float, c_int, c_uchar};

use std::sync::Mutex;

static mut CUSTOM_FONT: Option<Font> = None;
static mut ICON_FONT: Option<Font> = None;
static TEXTURES: Mutex<Option<HashMap<i32, Texture2D>>> = Mutex::new(None);
static mut NEXT_TEXTURE_ID: i32 = 1;

fn with_textures<F, R>(f: F) -> R
where
    F: FnOnce(&mut HashMap<i32, Texture2D>) -> R,
{
    let mut guard = TEXTURES.lock().unwrap();
    let map = guard.get_or_insert_with(HashMap::new);
    f(map)
}

pub fn load_font(file_path: *const c_char, font_size: c_int) -> i32 {
    unsafe {
        if let Some(old_font) = CUSTOM_FONT {
            UnloadFont(old_font);
            CUSTOM_FONT = None;
        }
        let mut codepoints: Vec<c_int> = Vec::new();
        // ASCII 32..=126
        for c in 32..=126 {
            codepoints.push(c);
        }
        // Latin-1 Supplement (Español: á, é, í, ó, ú, ñ, ¿, ¡, Á, É, Í, Ó, Ú, Ñ, ü, etc.): 160..=255
        for c in 160..=255 {
            codepoints.push(c);
        }
        // Latin Extended-A: 256..=383
        for c in 256..=383 {
            codepoints.push(c);
        }
        // Símbolos de Puntuación, Matemáticos y Divisas (€, $, £, ¥, •, –, —, …, °, ±, etc.): 8192..=8383
        for c in 8192..=8383 {
            codepoints.push(c);
        }

        let font = LoadFontEx(
            file_path,
            font_size,
            codepoints.as_mut_ptr(),
            codepoints.len() as c_int,
        );
        if font.texture.id > 0 {
            SetTextureFilter(font.texture, 1);
            CUSTOM_FONT = Some(font);
            1
        } else {
            0
        }
    }
}

pub fn load_icon_font(file_path: *const c_char, font_size: c_int) -> i32 {
    unsafe {
        if let Some(old_font) = ICON_FONT {
            UnloadFont(old_font);
            ICON_FONT = None;
        }
        let mut codepoints: Vec<c_int> = Vec::new();
        for c in 32..=126 {
            codepoints.push(c);
        }
        for c in 0xE000..=0xEBFF {
            codepoints.push(c);
        }
        let font = LoadFontEx(
            file_path,
            font_size,
            codepoints.as_mut_ptr(),
            codepoints.len() as c_int,
        );
        if font.texture.id > 0 {
            SetTextureFilter(font.texture, 1);
            ICON_FONT = Some(font);
            1
        } else {
            0
        }
    }
}

pub fn draw_rect(x: c_int, y: c_int, w: c_int, h: c_int, color: Color) {
    unsafe { DrawRectangle(x, y, w, h, color) }
}

pub fn draw_rect_lines(x: c_int, y: c_int, w: c_int, h: c_int, color: Color) {
    unsafe { DrawRectangleLines(x, y, w, h, color) }
}

pub fn draw_circle(center_x: c_int, center_y: c_int, radius: c_float, color: Color) {
    unsafe { DrawCircle(center_x, center_y, radius, color) }
}

pub fn draw_circle_lines(center_x: c_int, center_y: c_int, radius: c_float, color: Color) {
    unsafe { DrawCircleLines(center_x, center_y, radius, color) }
}

pub fn draw_arc(
    center_x: c_int,
    center_y: c_int,
    radius: c_float,
    start_angle: c_float,
    end_angle: c_float,
    segments: c_int,
    color: Color,
) {
    unsafe {
        DrawCircleSector(
            Vector2 {
                x: center_x as f32,
                y: center_y as f32,
            },
            radius,
            start_angle,
            end_angle,
            segments,
            color,
        )
    }
}

pub fn draw_arc_lines(
    center_x: c_int,
    center_y: c_int,
    radius: c_float,
    start_angle: c_float,
    end_angle: c_float,
    segments: c_int,
    color: Color,
) {
    unsafe {
        DrawCircleSectorLines(
            Vector2 {
                x: center_x as f32,
                y: center_y as f32,
            },
            radius,
            start_angle,
            end_angle,
            segments,
            color,
        )
    }
}

pub fn draw_text(text: *const c_char, x: c_int, y: c_int, font_size: c_int, color: Color) {
    unsafe {
        if text.is_null() {
            return;
        }
        let c_str = std::ffi::CStr::from_ptr(text);
        if let Ok(str_slice) = c_str.to_str() {
            let contains_icon = str_slice
                .chars()
                .any(|ch| (ch as u32) >= 0xE000 && (ch as u32) <= 0xF8FF);
            if contains_icon {
                if let Some(icon_font) = ICON_FONT {
                    DrawTextEx(
                        icon_font,
                        text,
                        Vector2 {
                            x: x as f32,
                            y: y as f32,
                        },
                        font_size as f32,
                        1.0,
                        color,
                    );
                    return;
                }
            }
        }

        if let Some(font) = CUSTOM_FONT {
            DrawTextEx(
                font,
                text,
                Vector2 {
                    x: x as f32,
                    y: y as f32,
                },
                font_size as f32,
                1.0,
                color,
            );
        } else {
            DrawText(text, x, y, font_size, color);
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_load_font(file_path: *const c_char, font_size: c_int) -> i32 {
    load_font(file_path, font_size)
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_load_icon_font(file_path: *const c_char, font_size: c_int) -> i32 {
    load_icon_font(file_path, font_size)
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_draw_rect(
    x: c_int,
    y: c_int,
    w: c_int,
    h: c_int,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    draw_rect(x, y, w, h, Color { r, g, b, a });
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_draw_rect_lines(
    x: c_int,
    y: c_int,
    w: c_int,
    h: c_int,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    draw_rect_lines(x, y, w, h, Color { r, g, b, a });
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_draw_circle(
    center_x: c_int,
    center_y: c_int,
    radius: c_float,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    draw_circle(center_x, center_y, radius, Color { r, g, b, a });
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_draw_circle_lines(
    center_x: c_int,
    center_y: c_int,
    radius: c_float,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    draw_circle_lines(center_x, center_y, radius, Color { r, g, b, a });
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_draw_arc(
    center_x: c_int,
    center_y: c_int,
    radius: c_float,
    start_angle: c_float,
    end_angle: c_float,
    segments: c_int,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    draw_arc(
        center_x,
        center_y,
        radius,
        start_angle,
        end_angle,
        segments,
        Color { r, g, b, a },
    );
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_draw_arc_lines(
    center_x: c_int,
    center_y: c_int,
    radius: c_float,
    start_angle: c_float,
    end_angle: c_float,
    segments: c_int,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    draw_arc_lines(
        center_x,
        center_y,
        radius,
        start_angle,
        end_angle,
        segments,
        Color { r, g, b, a },
    );
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_draw_text(
    text: *const c_char,
    x: c_int,
    y: c_int,
    font_size: c_int,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    draw_text(text, x, y, font_size, Color { r, g, b, a });
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_load_texture(file_path: *const c_char) -> c_int {
    if file_path.is_null() {
        return 0;
    }
    unsafe {
        let texture = LoadTexture(file_path);
        if texture.id > 0 {
            SetTextureFilter(texture, 1);
            let id = NEXT_TEXTURE_ID;
            NEXT_TEXTURE_ID += 1;
            with_textures(|map| {
                map.insert(id, texture);
            });
            id
        } else {
            0
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_draw_texture(
    texture_id: c_int,
    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,
    rotation: c_float,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    with_textures(|map| {
        if let Some(texture) = map.get(&texture_id) {
            let dest_w = if width > 0 { width as f32 } else { texture.width as f32 };
            let dest_h = if height > 0 { height as f32 } else { texture.height as f32 };
            let source = Rectangle {
                x: 0.0,
                y: 0.0,
                width: texture.width as f32,
                height: texture.height as f32,
            };
            let dest = Rectangle {
                x: x as f32,
                y: y as f32,
                width: dest_w,
                height: dest_h,
            };
            let origin = Vector2 { x: 0.0, y: 0.0 };
            unsafe {
                DrawTexturePro(*texture, source, dest, origin, rotation, Color { r, g, b, a });
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_get_texture_width(texture_id: c_int) -> c_int {
    with_textures(|map| {
        map.get(&texture_id).map_or(0, |texture| texture.width)
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_get_texture_height(texture_id: c_int) -> c_int {
    with_textures(|map| {
        map.get(&texture_id).map_or(0, |texture| texture.height)
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_unload_texture(texture_id: c_int) -> c_int {
    let texture = with_textures(|map| map.remove(&texture_id));
    if let Some(texture) = texture {
        unsafe {
            UnloadTexture(texture);
        }
        1
    } else {
        0
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_draw_round_rect(
    x: c_int,
    y: c_int,
    w: c_int,
    h: c_int,
    roundness: c_float,
    segments: c_int,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    let rec = Rectangle {
        x: x as f32,
        y: y as f32,
        width: w as f32,
        height: h as f32,
    };
    unsafe {
        DrawRectangleRounded(rec, roundness, segments, Color { r, g, b, a });
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_draw_round_rect_lines(
    x: c_int,
    y: c_int,
    w: c_int,
    h: c_int,
    roundness: c_float,
    segments: c_int,
    line_thick: c_float,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    let rec = Rectangle {
        x: x as f32,
        y: y as f32,
        width: w as f32,
        height: h as f32,
    };
    unsafe {
        DrawRectangleRoundedLinesEx(rec, roundness, segments, line_thick, Color { r, g, b, a });
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_draw_poly(
    center_x: c_int,
    center_y: c_int,
    sides: c_int,
    radius: c_float,
    rotation: c_float,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    let center = Vector2 {
        x: center_x as f32,
        y: center_y as f32,
    };
    unsafe {
        DrawPoly(center, sides, radius, rotation, Color { r, g, b, a });
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_draw_poly_lines(
    center_x: c_int,
    center_y: c_int,
    sides: c_int,
    radius: c_float,
    rotation: c_float,
    line_thick: c_float,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    let center = Vector2 {
        x: center_x as f32,
        y: center_y as f32,
    };
    unsafe {
        DrawPolyLinesEx(center, sides, radius, rotation, line_thick, Color { r, g, b, a });
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_draw_triangle(
    x1: c_int,
    y1: c_int,
    x2: c_int,
    y2: c_int,
    x3: c_int,
    y3: c_int,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    let v1 = Vector2 { x: x1 as f32, y: y1 as f32 };
    let v2 = Vector2 { x: x2 as f32, y: y2 as f32 };
    let v3 = Vector2 { x: x3 as f32, y: y3 as f32 };
    unsafe {
        DrawTriangle(v1, v2, v3, Color { r, g, b, a });
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn g2d_draw_triangle_lines(
    x1: c_int,
    y1: c_int,
    x2: c_int,
    y2: c_int,
    x3: c_int,
    y3: c_int,
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
) {
    let v1 = Vector2 { x: x1 as f32, y: y1 as f32 };
    let v2 = Vector2 { x: x2 as f32, y: y2 as f32 };
    let v3 = Vector2 { x: x3 as f32, y: y3 as f32 };
    unsafe {
        DrawTriangleLines(v1, v2, v3, Color { r, g, b, a });
    }
}
