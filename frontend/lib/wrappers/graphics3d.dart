import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:frontend/ffi/lib_loader.dart';
import '../ffi/graphics3d_bindings.dart';

/// Wrapper de bajo nivel sobre las funciones FFI de graphics3d.
/// Contiene solo los lookups y llamadas directas; la lógica de alto nivel
/// vive en [Context3D].
class Graphics3D {
  // B1: cámara + primitivas existentes
  late final G3dBeginMode _beginMode;
  late final G3dVoidAction _endMode;
  late final G3dDrawGrid _drawGrid;
  late final G3dDrawBox _drawBox;
  late final G3dDrawBox _drawBoxWires;
  late final G3dDrawLine3D _drawLine3D;
  late final G3dDrawSphere _drawSphere;
  late final G3dDrawSphereEx _drawSphereEx;
  late final G3dDrawSphereEx _drawSphereWires;
  late final G3dDrawCylinder _drawCylinder;
  late final G3dDrawCylinderEx _drawCylinderEx;
  late final G3dDrawCylinder _drawCylinderWires;
  late final G3dDrawCylinderEx _drawCylinderWiresEx;
  late final G3dDrawPlane _drawPlane;
  // B2: modelos
  late final G3dModelLoad _modelLoad;
  late final G3dModelIntAction _modelUnload;
  late final G3dModelDraw _modelDraw;
  late final G3dModelDrawEx _modelDrawEx;
  late final G3dModelDraw _modelDrawWires;

  // F1: Mallas procedurales
  late final G3dModelGenCube _modelGenCube;
  late final G3dModelGenSphere _modelGenSphere;
  late final G3dModelGenCylinder _modelGenCylinder;
  late final G3dModelGenCone _modelGenCone;
  late final G3dModelGenPlane _modelGenPlane;

  // B3 & F4: picking
  late final G3dGetMouseRay _getMouseRay;
  late final G3dRayHitsBox _rayHitsBox;
  late final G3dRayHitsModelMesh _rayHitsModelMesh;
  // B4: bounding box
  late final G3dDrawBbox _drawBbox;
  late final G3dModelGetBbox _modelGetBbox;
  // B5: shaders
  late final G3dShaderLoad _shaderLoad;
  late final G3dShaderLoad _shaderLoadFromMemory;
  late final G3dShaderIntAction _shaderUnload;
  late final G3dShaderIntAction _shaderBegin;
  late final G3dVoidAction _shaderEnd;
  late final G3dShaderGetLocation _shaderGetLocation;
  late final G3dShaderSetFloat _shaderSetFloat;
  late final G3dShaderSetVec2 _shaderSetVec2;
  late final G3dShaderSetVec3 _shaderSetVec3;
  late final G3dShaderSetVec4 _shaderSetVec4;
  late final G3dShaderSetInt _shaderSetInt;
  late final G3dShaderSetTexture _shaderSetTexture;
  late final G3dShaderSetMatrix _shaderSetMatrix;
  // B6: materiales
  late final G3dModelSetMaterialTexture _modelSetMaterialTexture;
  late final G3dModelIntQuery _modelMaterialCount;
  late final G3dModelIntQuery _modelMeshCount;
  // B7: animaciones
  late final G3dAnimLoad _animLoad;
  late final G3dAnimSetInt _animUnload;
  late final G3dAnimSetIntQuery _animCount;
  late final G3dAnimFrameCount _animFrameCount;
  late final G3dAnimUpdate _animUpdate;
  late final G3dAnimIsValid _animIsValid;
  // B8: cámara orbital
  late final G3dCameraUpdate _cameraUpdate;

  Graphics3D() {
    final dylib = loadNativeLibrary();

    // B1
    _beginMode = dylib.lookupFunction<G3dBeginModeC, G3dBeginMode>(
      'g3d_begin_mode',
    );
    _endMode = dylib.lookupFunction<G3dVoidActionC, G3dVoidAction>(
      'g3d_end_mode',
    );
    _drawGrid = dylib.lookupFunction<G3dDrawGridC, G3dDrawGrid>(
      'g3d_draw_grid',
    );
    _drawBox = dylib.lookupFunction<G3dDrawBoxC, G3dDrawBox>('g3d_draw_box');
    _drawBoxWires = dylib.lookupFunction<G3dDrawBoxC, G3dDrawBox>(
      'g3d_draw_box_wires',
    );
    _drawLine3D = dylib.lookupFunction<G3dDrawLine3DC, G3dDrawLine3D>(
      'g3d_draw_line3d',
    );
    _drawSphere = dylib.lookupFunction<G3dDrawSphereC, G3dDrawSphere>(
      'g3d_draw_sphere',
    );
    _drawSphereEx = dylib.lookupFunction<G3dDrawSphereExC, G3dDrawSphereEx>(
      'g3d_draw_sphere_ex',
    );
    _drawSphereWires = dylib.lookupFunction<G3dDrawSphereExC, G3dDrawSphereEx>(
      'g3d_draw_sphere_wires',
    );
    _drawCylinder = dylib.lookupFunction<G3dDrawCylinderC, G3dDrawCylinder>(
      'g3d_draw_cylinder',
    );
    _drawCylinderEx = dylib
        .lookupFunction<G3dDrawCylinderExC, G3dDrawCylinderEx>(
          'g3d_draw_cylinder_ex',
        );
    _drawCylinderWires = dylib
        .lookupFunction<G3dDrawCylinderC, G3dDrawCylinder>(
          'g3d_draw_cylinder_wires',
        );
    _drawCylinderWiresEx = dylib
        .lookupFunction<G3dDrawCylinderExC, G3dDrawCylinderEx>(
          'g3d_draw_cylinder_wires_ex',
        );
    _drawPlane = dylib.lookupFunction<G3dDrawPlaneC, G3dDrawPlane>(
      'g3d_draw_plane',
    );
    // B2
    _modelLoad = dylib.lookupFunction<G3dModelLoadC, G3dModelLoad>(
      'g3d_model_load',
    );
    _modelUnload = dylib.lookupFunction<G3dModelIntActionC, G3dModelIntAction>(
      'g3d_model_unload',
    );
    _modelDraw = dylib.lookupFunction<G3dModelDrawC, G3dModelDraw>(
      'g3d_model_draw',
    );
    _modelDrawEx = dylib.lookupFunction<G3dModelDrawExC, G3dModelDrawEx>(
      'g3d_model_draw_ex',
    );
    _modelDrawWires = dylib.lookupFunction<G3dModelDrawC, G3dModelDraw>(
      'g3d_model_draw_wires',
    );

    // F1
    _modelGenCube = dylib.lookupFunction<G3dModelGenCubeC, G3dModelGenCube>(
      'g3d_model_gen_cube',
    );
    _modelGenSphere = dylib
        .lookupFunction<G3dModelGenSphereC, G3dModelGenSphere>(
          'g3d_model_gen_sphere',
        );
    _modelGenCylinder = dylib
        .lookupFunction<G3dModelGenCylinderC, G3dModelGenCylinder>(
          'g3d_model_gen_cylinder',
        );
    _modelGenCone = dylib.lookupFunction<G3dModelGenConeC, G3dModelGenCone>(
      'g3d_model_gen_cone',
    );
    _modelGenPlane = dylib.lookupFunction<G3dModelGenPlaneC, G3dModelGenPlane>(
      'g3d_model_gen_plane',
    );

    // B3 & F4
    _getMouseRay = dylib.lookupFunction<G3dGetMouseRayC, G3dGetMouseRay>(
      'g3d_get_mouse_ray',
    );
    _rayHitsBox = dylib.lookupFunction<G3dRayHitsBoxC, G3dRayHitsBox>(
      'g3d_ray_hits_box',
    );
    _rayHitsModelMesh = dylib
        .lookupFunction<G3dRayHitsModelMeshC, G3dRayHitsModelMesh>(
          'g3d_ray_hits_model_mesh',
        );
    // B4
    _drawBbox = dylib.lookupFunction<G3dDrawBboxC, G3dDrawBbox>(
      'g3d_draw_bbox',
    );
    _modelGetBbox = dylib.lookupFunction<G3dModelGetBboxC, G3dModelGetBbox>(
      'g3d_model_get_bbox',
    );
    // B5
    _shaderLoad = dylib.lookupFunction<G3dShaderLoadC, G3dShaderLoad>(
      'g3d_shader_load',
    );
    _shaderLoadFromMemory = dylib.lookupFunction<G3dShaderLoadC, G3dShaderLoad>(
      'g3d_shader_load_from_memory',
    );
    _shaderUnload = dylib
        .lookupFunction<G3dShaderIntActionC, G3dShaderIntAction>(
          'g3d_shader_unload',
        );
    _shaderBegin = dylib
        .lookupFunction<G3dShaderIntActionC, G3dShaderIntAction>(
          'g3d_shader_begin',
        );
    _shaderEnd = dylib.lookupFunction<G3dVoidActionC, G3dVoidAction>(
      'g3d_shader_end',
    );
    _shaderGetLocation = dylib
        .lookupFunction<G3dShaderGetLocationC, G3dShaderGetLocation>(
          'g3d_shader_get_location',
        );
    _shaderSetFloat = dylib
        .lookupFunction<G3dShaderSetFloatC, G3dShaderSetFloat>(
          'g3d_shader_set_float',
        );
    _shaderSetVec2 = dylib.lookupFunction<G3dShaderSetVec2C, G3dShaderSetVec2>(
      'g3d_shader_set_vec2',
    );
    _shaderSetVec3 = dylib.lookupFunction<G3dShaderSetVec3C, G3dShaderSetVec3>(
      'g3d_shader_set_vec3',
    );
    _shaderSetVec4 = dylib.lookupFunction<G3dShaderSetVec4C, G3dShaderSetVec4>(
      'g3d_shader_set_vec4',
    );
    _shaderSetInt = dylib.lookupFunction<G3dShaderSetIntC, G3dShaderSetInt>(
      'g3d_shader_set_int',
    );
    _shaderSetTexture = dylib
        .lookupFunction<G3dShaderSetTextureC, G3dShaderSetTexture>(
          'g3d_shader_set_texture',
        );
    _shaderSetMatrix = dylib
        .lookupFunction<G3dShaderSetMatrixC, G3dShaderSetMatrix>(
          'g3d_shader_set_matrix',
        );
    // B6
    _modelSetMaterialTexture = dylib
        .lookupFunction<
          G3dModelSetMaterialTextureC,
          G3dModelSetMaterialTexture
        >('g3d_model_set_material_texture');
    _modelMaterialCount = dylib
        .lookupFunction<G3dModelIntQueryC, G3dModelIntQuery>(
          'g3d_model_material_count',
        );
    _modelMeshCount = dylib.lookupFunction<G3dModelIntQueryC, G3dModelIntQuery>(
      'g3d_model_mesh_count',
    );
    // B7
    _animLoad = dylib.lookupFunction<G3dAnimLoadC, G3dAnimLoad>(
      'g3d_anim_load',
    );
    _animUnload = dylib.lookupFunction<G3dAnimSetIntC, G3dAnimSetInt>(
      'g3d_anim_unload',
    );
    _animCount = dylib.lookupFunction<G3dAnimSetIntQueryC, G3dAnimSetIntQuery>(
      'g3d_anim_count',
    );
    _animFrameCount = dylib
        .lookupFunction<G3dAnimFrameCountC, G3dAnimFrameCount>(
          'g3d_anim_frame_count',
        );
    _animUpdate = dylib.lookupFunction<G3dAnimUpdateC, G3dAnimUpdate>(
      'g3d_anim_update',
    );
    _animIsValid = dylib.lookupFunction<G3dAnimIsValidC, G3dAnimIsValid>(
      'g3d_anim_is_valid',
    );
    // B8
    _cameraUpdate = dylib.lookupFunction<G3dCameraUpdateC, G3dCameraUpdate>(
      'g3d_camera_update',
    );
  }

  // ---------------------------------------------------------------------------
  // B1: Primitivas
  // ---------------------------------------------------------------------------

  void beginMode(
    double cx,
    double cy,
    double cz, [
    double tx = 0,
    double ty = 0,
    double tz = 0,
    double upX = 0,
    double upY = 1,
    double upZ = 0,
    double fovy = 45,
    int projection = 0,
  ]) => _beginMode(cx, cy, cz, tx, ty, tz, upX, upY, upZ, fovy, projection);

  void endMode() => _endMode();
  void drawGrid(int slices, double spacing) => _drawGrid(slices, spacing);
  void drawBox(
    double x,
    double y,
    double z,
    double w,
    double h,
    double d,
    int r,
    int g,
    int b,
    int a,
  ) => _drawBox(x, y, z, w, h, d, r, g, b, a);
  void drawBoxWires(
    double x,
    double y,
    double z,
    double w,
    double h,
    double d,
    int r,
    int g,
    int b,
    int a,
  ) => _drawBoxWires(x, y, z, w, h, d, r, g, b, a);
  void drawLine3D(
    double sx,
    double sy,
    double sz,
    double ex,
    double ey,
    double ez,
    int r,
    int g,
    int b,
    int a,
  ) => _drawLine3D(sx, sy, sz, ex, ey, ez, r, g, b, a);
  void drawSphere(
    double x,
    double y,
    double z,
    double radius,
    int r,
    int g,
    int b,
    int a,
  ) => _drawSphere(x, y, z, radius, r, g, b, a);
  void drawSphereEx(
    double x,
    double y,
    double z,
    double radius,
    int rings,
    int slices,
    int r,
    int g,
    int b,
    int a,
  ) => _drawSphereEx(x, y, z, radius, rings, slices, r, g, b, a);
  void drawSphereWires(
    double x,
    double y,
    double z,
    double radius,
    int rings,
    int slices,
    int r,
    int g,
    int b,
    int a,
  ) => _drawSphereWires(x, y, z, radius, rings, slices, r, g, b, a);
  void drawCylinder(
    double x,
    double y,
    double z,
    double radius,
    double height,
    int slices,
    int r,
    int g,
    int b,
    int a,
  ) => _drawCylinder(x, y, z, radius, height, slices, r, g, b, a);
  void drawCylinderEx(
    double sx,
    double sy,
    double sz,
    double ex,
    double ey,
    double ez,
    double rs,
    double re,
    int slices,
    int r,
    int g,
    int b,
    int a,
  ) => _drawCylinderEx(sx, sy, sz, ex, ey, ez, rs, re, slices, r, g, b, a);
  void drawCylinderWires(
    double x,
    double y,
    double z,
    double radius,
    double height,
    int slices,
    int r,
    int g,
    int b,
    int a,
  ) => _drawCylinderWires(x, y, z, radius, height, slices, r, g, b, a);
  void drawCylinderWiresEx(
    double sx,
    double sy,
    double sz,
    double ex,
    double ey,
    double ez,
    double rs,
    double re,
    int slices,
    int r,
    int g,
    int b,
    int a,
  ) => _drawCylinderWiresEx(sx, sy, sz, ex, ey, ez, rs, re, slices, r, g, b, a);
  void drawPlane(
    double x,
    double y,
    double z,
    double width,
    double length,
    int r,
    int g,
    int b,
    int a,
  ) => _drawPlane(x, y, z, width, length, r, g, b, a);

  // ---------------------------------------------------------------------------
  // B2: Modelos
  // ---------------------------------------------------------------------------

  /// Carga un modelo desde [path]. Devuelve el handle (> 0) o 0 si falla.
  int modelLoad(String path) {
    final ptr = path.toNativeUtf8().cast<Char>();
    final id = _modelLoad(ptr);
    calloc.free(ptr);
    return id;
  }

  void modelUnload(int id) => _modelUnload(id);

  void modelDraw(
    int id,
    double x,
    double y,
    double z,
    double scale,
    int r,
    int g,
    int b,
    int a,
  ) => _modelDraw(id, x, y, z, scale, r, g, b, a);

  void modelDrawEx(
    int id,
    double x,
    double y,
    double z,
    double axisX,
    double axisY,
    double axisZ,
    double angle,
    double scaleX,
    double scaleY,
    double scaleZ,
    int r,
    int g,
    int b,
    int a,
  ) => _modelDrawEx(
    id,
    x,
    y,
    z,
    axisX,
    axisY,
    axisZ,
    angle,
    scaleX,
    scaleY,
    scaleZ,
    r,
    g,
    b,
    a,
  );

  void modelDrawWires(
    int id,
    double x,
    double y,
    double z,
    double scale,
    int r,
    int g,
    int b,
    int a,
  ) => _modelDrawWires(id, x, y, z, scale, r, g, b, a);

  // ---------------------------------------------------------------------------
  // F1: Mallas procedurales
  // ---------------------------------------------------------------------------

  int modelGenCube(double width, double height, double length) =>
      _modelGenCube(width, height, length);
  int modelGenSphere(double radius, int rings, int slices) =>
      _modelGenSphere(radius, rings, slices);
  int modelGenCylinder(double radius, double height, int slices) =>
      _modelGenCylinder(radius, height, slices);
  int modelGenCone(double radius, double height, int slices) =>
      _modelGenCone(radius, height, slices);
  int modelGenPlane(double width, double length, int resX, int resZ) =>
      _modelGenPlane(width, length, resX, resZ);

  // ---------------------------------------------------------------------------
  // B3 & F4: Picking
  // ---------------------------------------------------------------------------

  /// Construye un rayo desde la posición del cursor hacia el mundo 3D.
  /// Usa los parámetros de cámara actuales.
  (double ox, double oy, double oz, double dx, double dy, double dz)
  getMouseRay(
    double mouseX,
    double mouseY,
    double camX,
    double camY,
    double camZ,
    double targetX,
    double targetY,
    double targetZ,
    double upX,
    double upY,
    double upZ,
    double fovy,
    int projection,
  ) {
    final buf = calloc<Float>(6);
    _getMouseRay(
      mouseX,
      mouseY,
      camX,
      camY,
      camZ,
      targetX,
      targetY,
      targetZ,
      upX,
      upY,
      upZ,
      fovy,
      projection,
      buf + 0,
      buf + 1,
      buf + 2,
      buf + 3,
      buf + 4,
      buf + 5,
    );
    final result = (buf[0], buf[1], buf[2], buf[3], buf[4], buf[5]);
    calloc.free(buf);
    return result;
  }

  /// Comprueba si el rayo intersecta el AABB dado.
  /// Devuelve null si no hay intersección.
  ({
    double dist,
    double px,
    double py,
    double pz,
    double nx,
    double ny,
    double nz,
  })?
  rayHitsBox(
    double rox,
    double roy,
    double roz,
    double rdx,
    double rdy,
    double rdz,
    double bmnx,
    double bmny,
    double bmnz,
    double bmxx,
    double bmxy,
    double bmxz,
  ) {
    final buf = calloc<Float>(7);
    final hit = _rayHitsBox(
      rox,
      roy,
      roz,
      rdx,
      rdy,
      rdz,
      bmnx,
      bmny,
      bmnz,
      bmxx,
      bmxy,
      bmxz,
      buf + 0,
      buf + 1,
      buf + 2,
      buf + 3,
      buf + 4,
      buf + 5,
      buf + 6,
    );
    if (hit == 1) {
      final result = (
        dist: buf[0].toDouble(),
        px: buf[1].toDouble(),
        py: buf[2].toDouble(),
        pz: buf[3].toDouble(),
        nx: buf[4].toDouble(),
        ny: buf[5].toDouble(),
        nz: buf[6].toDouble(),
      );
      calloc.free(buf);
      return result;
    }
    calloc.free(buf);
    return null;
  }

  /// Comprueba si el rayo intersecta una malla específica del modelo.
  ({
    double dist,
    double px,
    double py,
    double pz,
    double nx,
    double ny,
    double nz,
  })?
  rayHitsModelMesh(
    double rox,
    double roy,
    double roz,
    double rdx,
    double rdy,
    double rdz,
    int modelId,
    int meshIndex,
    double m0,
    double m1,
    double m2,
    double m3,
    double m4,
    double m5,
    double m6,
    double m7,
    double m8,
    double m9,
    double m10,
    double m11,
    double m12,
    double m13,
    double m14,
    double m15,
  ) {
    final buf = calloc<Float>(7);
    final hit = _rayHitsModelMesh(
      rox,
      roy,
      roz,
      rdx,
      rdy,
      rdz,
      modelId,
      meshIndex,
      m0,
      m1,
      m2,
      m3,
      m4,
      m5,
      m6,
      m7,
      m8,
      m9,
      m10,
      m11,
      m12,
      m13,
      m14,
      m15,
      buf + 0,
      buf + 1,
      buf + 2,
      buf + 3,
      buf + 4,
      buf + 5,
      buf + 6,
    );
    if (hit == 1) {
      final result = (
        dist: buf[0].toDouble(),
        px: buf[1].toDouble(),
        py: buf[2].toDouble(),
        pz: buf[3].toDouble(),
        nx: buf[4].toDouble(),
        ny: buf[5].toDouble(),
        nz: buf[6].toDouble(),
      );
      calloc.free(buf);
      return result;
    }
    calloc.free(buf);
    return null;
  }

  // ---------------------------------------------------------------------------
  // B4: BoundingBox
  // ---------------------------------------------------------------------------

  void drawBbox(
    double minX,
    double minY,
    double minZ,
    double maxX,
    double maxY,
    double maxZ,
    int r,
    int g,
    int b,
    int a,
  ) => _drawBbox(minX, minY, minZ, maxX, maxY, maxZ, r, g, b, a);

  /// Obtiene el AABB del modelo. Devuelve null si el ID no existe.
  (
    double minX,
    double minY,
    double minZ,
    double maxX,
    double maxY,
    double maxZ,
  )?
  modelGetBbox(int id) {
    final buf = calloc<Float>(6);
    final ok = _modelGetBbox(
      id,
      buf + 0,
      buf + 1,
      buf + 2,
      buf + 3,
      buf + 4,
      buf + 5,
    );
    if (ok == 1) {
      final result = (
        buf[0].toDouble(),
        buf[1].toDouble(),
        buf[2].toDouble(),
        buf[3].toDouble(),
        buf[4].toDouble(),
        buf[5].toDouble(),
      );
      calloc.free(buf);
      return result;
    }
    calloc.free(buf);
    return null;
  }

  // ---------------------------------------------------------------------------
  // B5: Shaders
  // ---------------------------------------------------------------------------

  int shaderLoad(String? vsPath, String? fsPath) {
    final vs = vsPath?.toNativeUtf8().cast<Char>() ?? nullptr;
    final fs = fsPath?.toNativeUtf8().cast<Char>() ?? nullptr;
    final id = _shaderLoad(vs, fs);
    if (vs != nullptr) calloc.free(vs);
    if (fs != nullptr) calloc.free(fs);
    return id;
  }

  int shaderLoadFromMemory(String? vsCode, String? fsCode) {
    final vs = vsCode?.toNativeUtf8().cast<Char>() ?? nullptr;
    final fs = fsCode?.toNativeUtf8().cast<Char>() ?? nullptr;
    final id = _shaderLoadFromMemory(vs, fs);
    if (vs != nullptr) calloc.free(vs);
    if (fs != nullptr) calloc.free(fs);
    return id;
  }

  void shaderUnload(int id) => _shaderUnload(id);
  void shaderBegin(int id) => _shaderBegin(id);
  void shaderEnd() => _shaderEnd();

  int shaderGetLocation(int id, String name) {
    final ptr = name.toNativeUtf8().cast<Char>();
    final loc = _shaderGetLocation(id, ptr);
    calloc.free(ptr);
    return loc;
  }

  void shaderSetFloat(int id, int loc, double value) =>
      _shaderSetFloat(id, loc, value);
  void shaderSetVec2(int id, int loc, double x, double y) =>
      _shaderSetVec2(id, loc, x, y);
  void shaderSetVec3(int id, int loc, double x, double y, double z) =>
      _shaderSetVec3(id, loc, x, y, z);
  void shaderSetVec4(int id, int loc, double x, double y, double z, double w) =>
      _shaderSetVec4(id, loc, x, y, z, w);
  void shaderSetInt(int id, int loc, int value) =>
      _shaderSetInt(id, loc, value);
  void shaderSetTexture(int shaderId, int loc, int textureId) =>
      _shaderSetTexture(shaderId, loc, textureId);
  void shaderSetMatrix(
    int id,
    int loc,
    double m0,
    double m1,
    double m2,
    double m3,
    double m4,
    double m5,
    double m6,
    double m7,
    double m8,
    double m9,
    double m10,
    double m11,
    double m12,
    double m13,
    double m14,
    double m15,
  ) => _shaderSetMatrix(
    id,
    loc,
    m0,
    m1,
    m2,
    m3,
    m4,
    m5,
    m6,
    m7,
    m8,
    m9,
    m10,
    m11,
    m12,
    m13,
    m14,
    m15,
  );

  // ---------------------------------------------------------------------------
  // B6: Materiales
  // ---------------------------------------------------------------------------

  bool modelSetMaterialTexture(
    int modelId,
    int materialIndex,
    int mapType,
    int textureId,
  ) =>
      _modelSetMaterialTexture(modelId, materialIndex, mapType, textureId) == 1;

  int modelMaterialCount(int modelId) => _modelMaterialCount(modelId);
  int modelMeshCount(int modelId) => _modelMeshCount(modelId);

  // ---------------------------------------------------------------------------
  // B7: Animaciones
  // ---------------------------------------------------------------------------

  /// Carga animaciones desde un archivo. Devuelve (animSetId, count) o (0, 0) si falla.
  (int id, int count) animLoad(String path) {
    final ptr = path.toNativeUtf8().cast<Char>();
    final countBuf = calloc<Int32>();
    final id = _animLoad(ptr, countBuf);
    final count = countBuf.value;
    calloc.free(ptr);
    calloc.free(countBuf);
    return (id, count);
  }

  void animUnload(int animSetId) => _animUnload(animSetId);
  int animCount(int animSetId) => _animCount(animSetId);
  int animFrameCount(int animSetId, int animIndex) =>
      _animFrameCount(animSetId, animIndex);
  bool animUpdate(int modelId, int animSetId, int animIndex, double frame) =>
      _animUpdate(modelId, animSetId, animIndex, frame) == 1;
  bool animIsValid(int modelId, int animSetId, int animIndex) =>
      _animIsValid(modelId, animSetId, animIndex) == 1;

  // ---------------------------------------------------------------------------
  // B8: Cámara orbital
  // ---------------------------------------------------------------------------

  /// Actualiza la cámara con el modo dado y devuelve (posX, posY, posZ, targetX, targetY, targetZ).
  (double, double, double, double, double, double) cameraUpdate(
    int mode,
    double camX,
    double camY,
    double camZ,
    double targetX,
    double targetY,
    double targetZ,
    double upX,
    double upY,
    double upZ,
    double fovy,
    int projection,
  ) {
    final buf = calloc<Float>(6);
    _cameraUpdate(
      mode,
      camX,
      camY,
      camZ,
      targetX,
      targetY,
      targetZ,
      upX,
      upY,
      upZ,
      fovy,
      projection,
      buf + 0,
      buf + 1,
      buf + 2,
      buf + 3,
      buf + 4,
      buf + 5,
    );
    final result = (
      buf[0].toDouble(),
      buf[1].toDouble(),
      buf[2].toDouble(),
      buf[3].toDouble(),
      buf[4].toDouble(),
      buf[5].toDouble(),
    );
    calloc.free(buf);
    return result;
  }
}
