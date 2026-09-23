use raylib_sys::{
    BeginMode3D, BoundingBox, Camera3D, Color, DrawBoundingBox, DrawCube, DrawCubeWires,
    DrawCylinder, DrawCylinderEx, DrawCylinderWires, DrawCylinderWiresEx, DrawGrid, DrawLine3D,
    DrawModel, DrawModelEx, DrawModelWires, DrawPlane, DrawSphere, DrawSphereEx, DrawSphereWires,
    EndMode3D, GetModelBoundingBox, GetRayCollisionBox, GetScreenToWorldRay, LoadModel,
    Ray, UnloadModel, Vector2, Vector3,
};
use std::collections::HashMap;
use std::os::raw::{c_char, c_int, c_uchar};
use std::sync::atomic::{AtomicI32, Ordering};
use std::sync::Mutex;

// ---------------------------------------------------------------------------
// Modelos 3D: mapa de handles (patrón igual que audio)
// ---------------------------------------------------------------------------

struct ModelWrapper(raylib_sys::Model);
/// SAFETY: Raylib opera en un único hilo de render; los handles de modelo no se
/// comparten entre hilos de Dart durante el renderizado.
unsafe impl Send for ModelWrapper {}
unsafe impl Sync for ModelWrapper {}

static MODELS: Mutex<Option<HashMap<i32, ModelWrapper>>> = Mutex::new(None);
/// Contador atómico de IDs — `Relaxed` garantiza unicidad sin ordering adicional.
static NEXT_MODEL_ID: AtomicI32 = AtomicI32::new(1);

fn with_models<F, R>(f: F) -> R
where
    F: FnOnce(&mut HashMap<i32, ModelWrapper>) -> R,
{
    let mut guard = MODELS.lock().unwrap();
    let map = guard.get_or_insert_with(HashMap::new);
    f(map)
}

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

// ---------------------------------------------------------------------------
// Esfera
// ---------------------------------------------------------------------------

/// Dibuja una esfera sólida con la subdivisión por defecto de Raylib.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_draw_sphere(
    x: f32, y: f32, z: f32,
    radius: f32,
    r: c_uchar, g: c_uchar, b: c_uchar, a: c_uchar,
) {
    unsafe {
        DrawSphere(Vector3 { x, y, z }, radius, Color { r, g, b, a });
    }
}

/// Dibuja una esfera sólida con control de anillos y cortes (resolusión).
#[unsafe(no_mangle)]
pub extern "C" fn g3d_draw_sphere_ex(
    x: f32, y: f32, z: f32,
    radius: f32,
    rings: c_int,
    slices: c_int,
    r: c_uchar, g: c_uchar, b: c_uchar, a: c_uchar,
) {
    unsafe {
        DrawSphereEx(Vector3 { x, y, z }, radius, rings, slices, Color { r, g, b, a });
    }
}

/// Dibuja el wireframe de una esfera con control de anillos y cortes.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_draw_sphere_wires(
    x: f32, y: f32, z: f32,
    radius: f32,
    rings: c_int,
    slices: c_int,
    r: c_uchar, g: c_uchar, b: c_uchar, a: c_uchar,
) {
    unsafe {
        DrawSphereWires(Vector3 { x, y, z }, radius, rings, slices, Color { r, g, b, a });
    }
}

// ---------------------------------------------------------------------------
// Cilindro / Cono
// ---------------------------------------------------------------------------

/// Dibuja un cilindro sólido (radio uniforme).
/// `height` es la altura; el centro de la base inferior es la posición dada.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_draw_cylinder(
    x: f32, y: f32, z: f32,
    radius: f32,
    height: f32,
    slices: c_int,
    r: c_uchar, g: c_uchar, b: c_uchar, a: c_uchar,
) {
    unsafe {
        DrawCylinder(Vector3 { x, y, z }, radius, radius, height, slices, Color { r, g, b, a });
    }
}

/// Dibuja un tronco cónico (radios independientes en cada extremo).
/// Permite crear conos (`radius_top = 0`), cilindros o frustrums.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_draw_cylinder_ex(
    start_x: f32, start_y: f32, start_z: f32,
    end_x: f32, end_y: f32, end_z: f32,
    radius_start: f32,
    radius_end: f32,
    slices: c_int,
    r: c_uchar, g: c_uchar, b: c_uchar, a: c_uchar,
) {
    unsafe {
        DrawCylinderEx(
            Vector3 { x: start_x, y: start_y, z: start_z },
            Vector3 { x: end_x, y: end_y, z: end_z },
            radius_start, radius_end, slices,
            Color { r, g, b, a },
        );
    }
}

/// Dibuja el wireframe de un cilindro.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_draw_cylinder_wires(
    x: f32, y: f32, z: f32,
    radius: f32,
    height: f32,
    slices: c_int,
    r: c_uchar, g: c_uchar, b: c_uchar, a: c_uchar,
) {
    unsafe {
        DrawCylinderWires(Vector3 { x, y, z }, radius, radius, height, slices, Color { r, g, b, a });
    }
}

/// Dibuja el wireframe de un tronco cónico.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_draw_cylinder_wires_ex(
    start_x: f32, start_y: f32, start_z: f32,
    end_x: f32, end_y: f32, end_z: f32,
    radius_start: f32,
    radius_end: f32,
    slices: c_int,
    r: c_uchar, g: c_uchar, b: c_uchar, a: c_uchar,
) {
    unsafe {
        DrawCylinderWiresEx(
            Vector3 { x: start_x, y: start_y, z: start_z },
            Vector3 { x: end_x, y: end_y, z: end_z },
            radius_start, radius_end, slices,
            Color { r, g, b, a },
        );
    }
}

// ---------------------------------------------------------------------------
// Plano
// ---------------------------------------------------------------------------

/// Dibuja un plano horizontal centrado en (x, y, z) de tamaño width x length.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_draw_plane(
    x: f32, y: f32, z: f32,
    width: f32,
    length: f32,
    r: c_uchar, g: c_uchar, b: c_uchar, a: c_uchar,
) {
    unsafe {
        DrawPlane(
            Vector3 { x, y, z },
            Vector2 { x: width, y: length },
            Color { r, g, b, a },
        );
    }
}

// ===========================================================================
// BLOQUE 2 — Carga y renderizado de modelos (.obj / .gltf / etc.)
// ===========================================================================

/// Carga un modelo 3D desde disco y devuelve su handle (> 0).
/// Devuelve 0 si el archivo no existe o falla la carga.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_model_load(file_path: *const c_char) -> c_int {
    if file_path.is_null() {
        return 0;
    }
    let model = unsafe { LoadModel(file_path) };
    // Raylib pone meshCount = 0 cuando falla la carga
    if model.meshCount == 0 {
        return 0;
    }
    let id = NEXT_MODEL_ID.fetch_add(1, Ordering::Relaxed);
    with_models(|map| {
        map.insert(id, ModelWrapper(model));
    });
    id
}

/// Descarga el modelo de GPU/CPU y lo elimina del mapa de handles.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_model_unload(id: c_int) {
    with_models(|map| {
        if let Some(wrapper) = map.remove(&id) {
            unsafe { UnloadModel(wrapper.0) };
        }
    });
}

/// Dibuja el modelo en (x, y, z) con escala uniforme y tinte de color.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_model_draw(
    id: c_int,
    x: f32, y: f32, z: f32,
    scale: f32,
    r: c_uchar, g: c_uchar, b: c_uchar, a: c_uchar,
) {
    with_models(|map| {
        if let Some(wrapper) = map.get(&id) {
            unsafe {
                DrawModel(wrapper.0, Vector3 { x, y, z }, scale, Color { r, g, b, a });
            }
        }
    });
}

/// Dibuja el modelo con rotación y escala por eje (transformación completa).
/// `axis_x/y/z` define el eje de rotación (normalmente 0,1,0 para Y);
/// `angle` es en grados; `scale_x/y/z` permite escala no uniforme.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_model_draw_ex(
    id: c_int,
    x: f32, y: f32, z: f32,
    axis_x: f32, axis_y: f32, axis_z: f32,
    angle: f32,
    scale_x: f32, scale_y: f32, scale_z: f32,
    r: c_uchar, g: c_uchar, b: c_uchar, a: c_uchar,
) {
    with_models(|map| {
        if let Some(wrapper) = map.get(&id) {
            unsafe {
                DrawModelEx(
                    wrapper.0,
                    Vector3 { x, y, z },
                    Vector3 { x: axis_x, y: axis_y, z: axis_z },
                    angle,
                    Vector3 { x: scale_x, y: scale_y, z: scale_z },
                    Color { r, g, b, a },
                );
            }
        }
    });
}

/// Dibuja solo el wireframe del modelo.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_model_draw_wires(
    id: c_int,
    x: f32, y: f32, z: f32,
    scale: f32,
    r: c_uchar, g: c_uchar, b: c_uchar, a: c_uchar,
) {
    with_models(|map| {
        if let Some(wrapper) = map.get(&id) {
            unsafe {
                DrawModelWires(wrapper.0, Vector3 { x, y, z }, scale, Color { r, g, b, a });
            }
        }
    });
}

// ===========================================================================
// BLOQUE 3 — Ray casting / Picking 3D
// ===========================================================================

/// Construye un rayo desde la posición del cursor en pantalla hacia el mundo 3D.
/// Rellena los 6 floats de salida: origen (ox, oy, oz) y dirección (dx, dy, dz).
/// La cámara se especifica con los mismos parámetros que `g3d_begin_mode`.
///
/// # Safety
/// Los punteros de salida deben ser válidos y no nulos.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_get_mouse_ray(
    mouse_x: f32, mouse_y: f32,
    cam_x: f32, cam_y: f32, cam_z: f32,
    target_x: f32, target_y: f32, target_z: f32,
    up_x: f32, up_y: f32, up_z: f32,
    fovy: f32,
    projection: c_int,
    out_ox: *mut f32, out_oy: *mut f32, out_oz: *mut f32,
    out_dx: *mut f32, out_dy: *mut f32, out_dz: *mut f32,
) {
    let camera = Camera3D {
        position:  Vector3 { x: cam_x,    y: cam_y,    z: cam_z    },
        target:    Vector3 { x: target_x, y: target_y, z: target_z },
        up:        Vector3 { x: up_x,     y: up_y,     z: up_z     },
        fovy,
        projection,
    };
    let ray: Ray = unsafe {
        GetScreenToWorldRay(Vector2 { x: mouse_x, y: mouse_y }, camera)
    };
    unsafe {
        *out_ox = ray.position.x;
        *out_oy = ray.position.y;
        *out_oz = ray.position.z;
        *out_dx = ray.direction.x;
        *out_dy = ray.direction.y;
        *out_dz = ray.direction.z;
    }
}

/// Comprueba si un rayo intersecta con un AABB (Axis-Aligned Bounding Box).
/// Devuelve 1 si hay colisión, 0 si no.
/// Si hay colisión, rellena: distancia, punto de impacto (px/py/pz) y normal (nx/ny/nz).
///
/// # Safety
/// Los punteros de salida deben ser válidos y no nulos.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_ray_hits_box(
    ray_ox: f32, ray_oy: f32, ray_oz: f32,
    ray_dx: f32, ray_dy: f32, ray_dz: f32,
    box_min_x: f32, box_min_y: f32, box_min_z: f32,
    box_max_x: f32, box_max_y: f32, box_max_z: f32,
    out_dist: *mut f32,
    out_px: *mut f32, out_py: *mut f32, out_pz: *mut f32,
    out_nx: *mut f32, out_ny: *mut f32, out_nz: *mut f32,
) -> c_int {
    let ray = Ray {
        position:  Vector3 { x: ray_ox, y: ray_oy, z: ray_oz },
        direction: Vector3 { x: ray_dx, y: ray_dy, z: ray_dz },
    };
    let bbox = BoundingBox {
        min: Vector3 { x: box_min_x, y: box_min_y, z: box_min_z },
        max: Vector3 { x: box_max_x, y: box_max_y, z: box_max_z },
    };
    let col = unsafe { GetRayCollisionBox(ray, bbox) };
    if col.hit {
        unsafe {
            *out_dist = col.distance;
            *out_px = col.point.x;
            *out_py = col.point.y;
            *out_pz = col.point.z;
            *out_nx = col.normal.x;
            *out_ny = col.normal.y;
            *out_nz = col.normal.z;
        }
        1
    } else {
        0
    }
}

// ===========================================================================
// BLOQUE 4 — BoundingBox: visualización y consulta
// ===========================================================================

/// Dibuja el contorno wireframe de un AABB con el color indicado.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_draw_bbox(
    min_x: f32, min_y: f32, min_z: f32,
    max_x: f32, max_y: f32, max_z: f32,
    r: c_uchar, g: c_uchar, b: c_uchar, a: c_uchar,
) {
    let bbox = BoundingBox {
        min: Vector3 { x: min_x, y: min_y, z: min_z },
        max: Vector3 { x: max_x, y: max_y, z: max_z },
    };
    unsafe { DrawBoundingBox(bbox, Color { r, g, b, a }) }
}

/// Obtiene el AABB del modelo identificado por `id`.
/// Devuelve 1 si el modelo existe y rellena los 6 floats de salida; 0 si no.
///
/// # Safety
/// Los punteros de salida deben ser válidos y no nulos.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_model_get_bbox(
    id: c_int,
    out_min_x: *mut f32, out_min_y: *mut f32, out_min_z: *mut f32,
    out_max_x: *mut f32, out_max_y: *mut f32, out_max_z: *mut f32,
) -> c_int {
    with_models(|map| {
        if let Some(wrapper) = map.get(&id) {
            let bbox = unsafe { GetModelBoundingBox(wrapper.0) };
            unsafe {
                *out_min_x = bbox.min.x;
                *out_min_y = bbox.min.y;
                *out_min_z = bbox.min.z;
                *out_max_x = bbox.max.x;
                *out_max_y = bbox.max.y;
                *out_max_z = bbox.max.z;
            }
            1
        } else {
            0
        }
    })
}

// ===========================================================================
// BLOQUE 5 — Shaders
// ===========================================================================

use raylib_sys::{
    BeginShaderMode, EndShaderMode, GetShaderLocation, IsShaderValid, LoadShader,
    LoadShaderFromMemory, Matrix, SetShaderValue, SetShaderValueMatrix, SetShaderValueTexture,
    Shader, UnloadShader,
};

struct ShaderWrapper(Shader);
unsafe impl Send for ShaderWrapper {}
unsafe impl Sync for ShaderWrapper {}

static SHADERS: Mutex<Option<HashMap<i32, ShaderWrapper>>> = Mutex::new(None);
static NEXT_SHADER_ID: AtomicI32 = AtomicI32::new(1);

fn with_shaders<F, R>(f: F) -> R
where
    F: FnOnce(&mut HashMap<i32, ShaderWrapper>) -> R,
{
    let mut guard = SHADERS.lock().unwrap();
    let map = guard.get_or_insert_with(HashMap::new);
    f(map)
}

/// Carga un shader desde archivos en disco.
/// Pasa `null` en `vs_path` para usar el vertex shader por defecto de Raylib.
/// Pasa `null` en `fs_path` para usar el fragment shader por defecto.
/// Devuelve un handle > 0, o 0 si el shader no es válido.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_shader_load(
    vs_path: *const c_char,
    fs_path: *const c_char,
) -> c_int {
    let shader = unsafe { LoadShader(vs_path, fs_path) };
    if !unsafe { IsShaderValid(shader) } {
        return 0;
    }
    let id = NEXT_SHADER_ID.fetch_add(1, Ordering::Relaxed);
    with_shaders(|map| map.insert(id, ShaderWrapper(shader)));
    id
}

/// Carga un shader desde cadenas de código GLSL en memoria.
/// Pasa `null` para usar el shader por defecto en alguno de los pasos.
/// Devuelve un handle > 0, o 0 si el shader no es válido.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_shader_load_from_memory(
    vs_code: *const c_char,
    fs_code: *const c_char,
) -> c_int {
    let shader = unsafe { LoadShaderFromMemory(vs_code, fs_code) };
    if !unsafe { IsShaderValid(shader) } {
        return 0;
    }
    let id = NEXT_SHADER_ID.fetch_add(1, Ordering::Relaxed);
    with_shaders(|map| map.insert(id, ShaderWrapper(shader)));
    id
}

/// Descarga el shader de GPU y lo elimina del mapa de handles.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_shader_unload(id: c_int) {
    with_shaders(|map| {
        if let Some(wrapper) = map.remove(&id) {
            unsafe { UnloadShader(wrapper.0) };
        }
    });
}

/// Activa el shader para las llamadas de dibujo siguientes.
/// Llama a `g3d_shader_end()` para restaurar el pipeline por defecto.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_shader_begin(id: c_int) {
    with_shaders(|map| {
        if let Some(wrapper) = map.get(&id) {
            unsafe { BeginShaderMode(wrapper.0) };
        }
    });
}

/// Desactiva el shader y restaura el pipeline de Raylib por defecto.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_shader_end() {
    unsafe { EndShaderMode() };
}

/// Obtiene la localización de un uniform por nombre.
/// Devuelve -1 si el uniform no existe en el shader.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_shader_get_location(id: c_int, name: *const c_char) -> c_int {
    with_shaders(|map| {
        if let Some(wrapper) = map.get(&id) {
            unsafe { GetShaderLocation(wrapper.0, name) }
        } else {
            -1
        }
    })
}

// Constantes de tipo de uniform (ShaderUniformDataType de Raylib)
const SHADER_UNIFORM_FLOAT: c_int = 0;
const SHADER_UNIFORM_VEC2: c_int = 1;
const SHADER_UNIFORM_VEC3: c_int = 2;
const SHADER_UNIFORM_VEC4: c_int = 3;
const SHADER_UNIFORM_INT: c_int = 4;

/// Establece un uniform float.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_shader_set_float(id: c_int, loc: c_int, value: f32) {
    with_shaders(|map| {
        if let Some(w) = map.get(&id) {
            unsafe { SetShaderValue(w.0, loc, &value as *const f32 as *const _, SHADER_UNIFORM_FLOAT) };
        }
    });
}

/// Establece un uniform vec2.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_shader_set_vec2(id: c_int, loc: c_int, x: f32, y: f32) {
    let v = [x, y];
    with_shaders(|map| {
        if let Some(w) = map.get(&id) {
            unsafe { SetShaderValue(w.0, loc, v.as_ptr() as *const _, SHADER_UNIFORM_VEC2) };
        }
    });
}

/// Establece un uniform vec3.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_shader_set_vec3(id: c_int, loc: c_int, x: f32, y: f32, z: f32) {
    let v = [x, y, z];
    with_shaders(|map| {
        if let Some(w) = map.get(&id) {
            unsafe { SetShaderValue(w.0, loc, v.as_ptr() as *const _, SHADER_UNIFORM_VEC3) };
        }
    });
}

/// Establece un uniform vec4 (también sirve para colores normalizados).
#[unsafe(no_mangle)]
pub extern "C" fn g3d_shader_set_vec4(id: c_int, loc: c_int, x: f32, y: f32, z: f32, w: f32) {
    let v = [x, y, z, w];
    with_shaders(|map| {
        if let Some(sw) = map.get(&id) {
            unsafe { SetShaderValue(sw.0, loc, v.as_ptr() as *const _, SHADER_UNIFORM_VEC4) };
        }
    });
}

/// Establece un uniform int.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_shader_set_int(id: c_int, loc: c_int, value: c_int) {
    with_shaders(|map| {
        if let Some(w) = map.get(&id) {
            unsafe { SetShaderValue(w.0, loc, &value as *const c_int as *const _, SHADER_UNIFORM_INT) };
        }
    });
}

/// Establece un uniform de textura (sampler2D) usando el ID del sistema de texturas 2D.
/// `texture_id` debe ser un ID válido devuelto por `g2d_load_texture`.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_shader_set_texture(shader_id: c_int, loc: c_int, texture_id: c_int) {
    let texture = crate::graphics2d::get_texture_by_id(texture_id);
    if let Some(tex) = texture {
        with_shaders(|map| {
            if let Some(w) = map.get(&shader_id) {
                unsafe { SetShaderValueTexture(w.0, loc, tex) };
            }
        });
    }
}

/// Establece un uniform mat4 (Matrix 4x4, row-major).
/// Los 16 valores se pasan en orden fila a fila: m0..m3 (fila 0), m4..m7 (fila 1), etc.
#[unsafe(no_mangle)]
#[allow(clippy::too_many_arguments)]
pub extern "C" fn g3d_shader_set_matrix(
    id: c_int, loc: c_int,
    m0: f32, m1: f32, m2: f32, m3: f32,
    m4: f32, m5: f32, m6: f32, m7: f32,
    m8: f32, m9: f32, m10: f32, m11: f32,
    m12: f32, m13: f32, m14: f32, m15: f32,
) {
    let mat = Matrix {
        m0, m4, m8,  m12,
        m1, m5, m9,  m13,
        m2, m6, m10, m14,
        m3, m7, m11, m15,
    };
    with_shaders(|map| {
        if let Some(w) = map.get(&id) {
            unsafe { SetShaderValueMatrix(w.0, loc, mat) };
        }
    });
}

// ===========================================================================
// BLOQUE 6 — Materiales
// ===========================================================================

use raylib_sys::SetMaterialTexture;

/// Asigna una textura 2D (por su ID del sistema de texturas) al slot `map_type` del
/// material `material_index` del modelo `model_id`.
///
/// Valores comunes de `map_type` (MaterialMapIndex de Raylib):
///   0 = MATERIAL_MAP_ALBEDO/DIFFUSE
///   1 = MATERIAL_MAP_METALNESS/SPECULAR
///   2 = MATERIAL_MAP_NORMAL
///   8 = MATERIAL_MAP_EMISSION
///   9 = MATERIAL_MAP_CUBEMAP
///
/// Devuelve 1 si el modelo y la textura existen, 0 si no.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_model_set_material_texture(
    model_id: c_int,
    material_index: c_int,
    map_type: c_int,
    texture_id: c_int,
) -> c_int {
    let texture = crate::graphics2d::get_texture_by_id(texture_id);
    let Some(tex) = texture else { return 0 };

    with_models(|map| {
        if let Some(wrapper) = map.get_mut(&model_id) {
            let model = &mut wrapper.0;
            if material_index >= 0 && material_index < model.materialCount {
                let material_ptr = unsafe { model.materials.add(material_index as usize) };
                unsafe { SetMaterialTexture(material_ptr, map_type, tex) };
                1
            } else {
                0
            }
        } else {
            0
        }
    })
}

/// Obtiene el número de materiales del modelo.
/// Devuelve -1 si el modelo no existe.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_model_material_count(model_id: c_int) -> c_int {
    with_models(|map| {
        map.get(&model_id).map_or(-1, |w| w.0.materialCount)
    })
}

/// Obtiene el número de meshes del modelo.
/// Devuelve -1 si el modelo no existe.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_model_mesh_count(model_id: c_int) -> c_int {
    with_models(|map| {
        map.get(&model_id).map_or(-1, |w| w.0.meshCount)
    })
}

// ===========================================================================
// BLOQUE 7 — Animaciones de modelos
// ===========================================================================

use raylib_sys::{IsModelAnimationValid, ModelAnimation, UnloadModelAnimations, UpdateModelAnimation};

struct AnimSetWrapper {
    ptr: *mut ModelAnimation,
    count: i32,
}
unsafe impl Send for AnimSetWrapper {}
unsafe impl Sync for AnimSetWrapper {}

static ANIM_SETS: Mutex<Option<HashMap<i32, AnimSetWrapper>>> = Mutex::new(None);
static NEXT_ANIM_SET_ID: AtomicI32 = AtomicI32::new(1);

fn with_anim_sets<F, R>(f: F) -> R
where
    F: FnOnce(&mut HashMap<i32, AnimSetWrapper>) -> R,
{
    let mut guard = ANIM_SETS.lock().unwrap();
    let map = guard.get_or_insert_with(HashMap::new);
    f(map)
}

/// Carga todas las animaciones de un archivo de modelo animado (`.glb`, `.iqm`, etc.).
/// Devuelve un handle de conjunto de animaciones (> 0) y escribe el número de
/// animaciones disponibles en `out_count`. Devuelve 0 si falla.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_anim_load(
    file_path: *const c_char,
    out_count: *mut c_int,
) -> c_int {
    if file_path.is_null() || out_count.is_null() {
        return 0;
    }
    let mut count: c_int = 0;
    let ptr = unsafe { raylib_sys::LoadModelAnimations(file_path, &mut count) };
    if ptr.is_null() || count == 0 {
        return 0;
    }
    unsafe { *out_count = count };
    let id = NEXT_ANIM_SET_ID.fetch_add(1, Ordering::Relaxed);
    with_anim_sets(|map| map.insert(id, AnimSetWrapper { ptr, count }));
    id
}

/// Libera todas las animaciones de un conjunto de animaciones cargado.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_anim_unload(anim_set_id: c_int) {
    with_anim_sets(|map| {
        if let Some(wrapper) = map.remove(&anim_set_id) {
            unsafe { UnloadModelAnimations(wrapper.ptr, wrapper.count) };
        }
    });
}

/// Devuelve el número de animaciones en el conjunto.
/// Devuelve -1 si el conjunto no existe.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_anim_count(anim_set_id: c_int) -> c_int {
    with_anim_sets(|map| map.get(&anim_set_id).map_or(-1, |w| w.count))
}

/// Devuelve el número de keyframes de una animación específica.
/// Devuelve -1 si el conjunto o el índice no son válidos.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_anim_frame_count(anim_set_id: c_int, anim_index: c_int) -> c_int {
    with_anim_sets(|map| {
        if let Some(wrapper) = map.get(&anim_set_id) {
            if anim_index >= 0 && anim_index < wrapper.count {
                let anim = unsafe { &*wrapper.ptr.add(anim_index as usize) };
                anim.keyframeCount
            } else {
                -1
            }
        } else {
            -1
        }
    })
}

/// Aplica el frame `frame` de la animación `anim_index` al modelo `model_id`.
/// `frame` es un float para permitir interpolación suave (Raylib la aplica internamente).
/// Devuelve 1 si la operación fue exitosa, 0 si algún ID o índice es inválido.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_anim_update(
    model_id: c_int,
    anim_set_id: c_int,
    anim_index: c_int,
    frame: f32,
) -> c_int {
    // Obtenemos copias independientes para no tener dos bloqueos simultáneos
    let model_copy = with_models(|map| map.get(&model_id).map(|w| w.0));
    let anim_copy = with_anim_sets(|map| {
        map.get(&anim_set_id).and_then(|wrapper| {
            if anim_index >= 0 && anim_index < wrapper.count {
                Some(unsafe { *wrapper.ptr.add(anim_index as usize) })
            } else {
                None
            }
        })
    });
    match (model_copy, anim_copy) {
        (Some(model), Some(anim)) => {
            unsafe { UpdateModelAnimation(model, anim, frame) };
            1
        }
        _ => 0,
    }
}

/// Comprueba si la animación es compatible con el modelo (misma estructura de huesos).
/// Devuelve 1 si es válida, 0 si no.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_anim_is_valid(
    model_id: c_int,
    anim_set_id: c_int,
    anim_index: c_int,
) -> c_int {
    let model_copy = with_models(|map| map.get(&model_id).map(|w| w.0));
    let anim_copy = with_anim_sets(|map| {
        map.get(&anim_set_id).and_then(|wrapper| {
            if anim_index >= 0 && anim_index < wrapper.count {
                Some(unsafe { *wrapper.ptr.add(anim_index as usize) })
            } else {
                None
            }
        })
    });
    match (model_copy, anim_copy) {
        (Some(model), Some(anim)) => {
            if unsafe { IsModelAnimationValid(model, anim) } { 1 } else { 0 }
        }
        _ => 0,
    }
}

// ===========================================================================
// BLOQUE 8 — Cámara orbital / navegación automática
// ===========================================================================

use raylib_sys::UpdateCamera;

/// Valores de modo de cámara (CameraMode de Raylib):
///   0 = CAMERA_CUSTOM        (solo lee/modifica la cámara, no aplica movimiento)
///   1 = CAMERA_FREE          (WASD + ratón para rotar)
///   2 = CAMERA_ORBITAL       (orbita alrededor del target con click izquierdo)
///   3 = CAMERA_FIRST_PERSON  (FPS estándar)
///   4 = CAMERA_THIRD_PERSON  (sigue al personaje)

/// Actualiza la cámara aplicando el modo de movimiento de Raylib.
/// Recibe los parámetros actuales de la cámara y escribe los nuevos en los punteros
/// de salida (posición y target pueden cambiar; up y fovy no cambian en la mayoría de modos).
///
/// # Safety
/// Los punteros de salida deben ser válidos y no nulos.
#[unsafe(no_mangle)]
pub extern "C" fn g3d_camera_update(
    mode: c_int,
    cam_x: f32, cam_y: f32, cam_z: f32,
    target_x: f32, target_y: f32, target_z: f32,
    up_x: f32, up_y: f32, up_z: f32,
    fovy: f32, projection: c_int,
    out_cam_x: *mut f32, out_cam_y: *mut f32, out_cam_z: *mut f32,
    out_target_x: *mut f32, out_target_y: *mut f32, out_target_z: *mut f32,
) {
    let mut camera = raylib_sys::Camera3D {
        position:  Vector3 { x: cam_x,    y: cam_y,    z: cam_z    },
        target:    Vector3 { x: target_x, y: target_y, z: target_z },
        up:        Vector3 { x: up_x,     y: up_y,     z: up_z     },
        fovy,
        projection,
    };
    unsafe {
        UpdateCamera(&mut camera, mode);
        *out_cam_x    = camera.position.x;
        *out_cam_y    = camera.position.y;
        *out_cam_z    = camera.position.z;
        *out_target_x = camera.target.x;
        *out_target_y = camera.target.y;
        *out_target_z = camera.target.z;
    }
}

// ===========================================================================
// BLOQUE 9 — Mallas procedurales (F1)
// ===========================================================================

use raylib_sys::{
    GenMeshCone, GenMeshCube, GenMeshCylinder, GenMeshPlane, GenMeshSphere, LoadModelFromMesh,
};

fn load_mesh_as_model(mesh: raylib_sys::Mesh) -> c_int {
    let model = unsafe { LoadModelFromMesh(mesh) };
    let id = NEXT_MODEL_ID.fetch_add(1, Ordering::Relaxed);
    with_models(|map| {
        map.insert(id, ModelWrapper(model));
    });
    id
}

#[unsafe(no_mangle)]
pub extern "C" fn g3d_model_gen_cube(width: f32, height: f32, length: f32) -> c_int {
    let mesh = unsafe { GenMeshCube(width, height, length) };
    load_mesh_as_model(mesh)
}

#[unsafe(no_mangle)]
pub extern "C" fn g3d_model_gen_sphere(radius: f32, rings: c_int, slices: c_int) -> c_int {
    let mesh = unsafe { GenMeshSphere(radius, rings, slices) };
    load_mesh_as_model(mesh)
}

#[unsafe(no_mangle)]
pub extern "C" fn g3d_model_gen_cylinder(radius: f32, height: f32, slices: c_int) -> c_int {
    let mesh = unsafe { GenMeshCylinder(radius, height, slices) };
    load_mesh_as_model(mesh)
}

#[unsafe(no_mangle)]
pub extern "C" fn g3d_model_gen_cone(radius: f32, height: f32, slices: c_int) -> c_int {
    let mesh = unsafe { GenMeshCone(radius, height, slices) };
    load_mesh_as_model(mesh)
}

#[unsafe(no_mangle)]
pub extern "C" fn g3d_model_gen_plane(width: f32, length: f32, res_x: c_int, res_z: c_int) -> c_int {
    let mesh = unsafe { GenMeshPlane(width, length, res_x, res_z) };
    load_mesh_as_model(mesh)
}

// ===========================================================================
// BLOQUE 10 — Picking a nivel malla (F4)
// ===========================================================================

use raylib_sys::GetRayCollisionMesh;

#[unsafe(no_mangle)]
pub extern "C" fn g3d_ray_hits_model_mesh(
    ray_ox: f32, ray_oy: f32, ray_oz: f32,
    ray_dx: f32, ray_dy: f32, ray_dz: f32,
    model_id: c_int,
    mesh_index: c_int,
    m0: f32, m1: f32, m2: f32, m3: f32,
    m4: f32, m5: f32, m6: f32, m7: f32,
    m8: f32, m9: f32, m10: f32, m11: f32,
    m12: f32, m13: f32, m14: f32, m15: f32,
    out_dist: *mut f32,
    out_px: *mut f32, out_py: *mut f32, out_pz: *mut f32,
    out_nx: *mut f32, out_ny: *mut f32, out_nz: *mut f32,
) -> c_int {
    let ray = Ray {
        position:  Vector3 { x: ray_ox, y: ray_oy, z: ray_oz },
        direction: Vector3 { x: ray_dx, y: ray_dy, z: ray_dz },
    };
    let transform = Matrix {
        m0, m4, m8,  m12,
        m1, m5, m9,  m13,
        m2, m6, m10, m14,
        m3, m7, m11, m15,
    };
    
    with_models(|map| {
        if let Some(wrapper) = map.get(&model_id) {
            let model = &wrapper.0;
            if mesh_index >= 0 && mesh_index < model.meshCount {
                let mesh = unsafe { *model.meshes.add(mesh_index as usize) };
                let col = unsafe { GetRayCollisionMesh(ray, mesh, transform) };
                if col.hit {
                    unsafe {
                        *out_dist = col.distance;
                        *out_px = col.point.x;
                        *out_py = col.point.y;
                        *out_pz = col.point.z;
                        *out_nx = col.normal.x;
                        *out_ny = col.normal.y;
                        *out_nz = col.normal.z;
                    }
                    return 1;
                }
            }
        }
        0
    })
}
