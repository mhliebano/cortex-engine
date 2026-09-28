import 'package:frontend/wrappers/graphics3d.dart';
import 'package:frontend/core/context2d.dart';

// ============================================================================
// Tipos de datos de alto nivel
// ============================================================================

/// Modos de proyección de cámara.
class CameraProjection {
  static const int perspective = 0;
  static const int orthographic = 1;
}

/// Modos de control automático de cámara (UpdateCamera de Raylib).
class CameraMode {
  static const int custom = 0;
  static const int free = 1;
  static const int orbital = 2;
  static const int firstPerson = 3;
  static const int thirdPerson = 4;
}

/// Slots de mapa de material (MaterialMapIndex de Raylib).
class MaterialMap {
  static const int albedo = 0; // difuso
  static const int metalness = 1; // especular
  static const int normal = 2;
  static const int roughness = 3;
  static const int occlusion = 4;
  static const int emission = 8;
  static const int cubemap = 9;
}

/// Datos de cámara 3D mutable. El SDK la usa para recordar el estado entre frames.
class Camera3DData {
  double posX, posY, posZ;
  double targetX, targetY, targetZ;
  double upX, upY, upZ;
  double fovy;
  int projection;

  Camera3DData({
    this.posX = 10.0,
    this.posY = 10.0,
    this.posZ = 10.0,
    this.targetX = 0.0,
    this.targetY = 0.0,
    this.targetZ = 0.0,
    this.upX = 0.0,
    this.upY = 1.0,
    this.upZ = 0.0,
    this.fovy = 45.0,
    this.projection = CameraProjection.perspective,
  });
}

/// Rayo 3D con origen y dirección.
class Ray3D {
  final double ox, oy, oz; // origen
  final double dx, dy, dz; // dirección (normalizada)

  const Ray3D({
    required this.ox,
    required this.oy,
    required this.oz,
    required this.dx,
    required this.dy,
    required this.dz,
  });
}

/// Resultado de una intersección rayo-caja.
class RayHit {
  final double distance;
  final double px, py, pz; // punto de impacto
  final double nx, ny, nz; // normal de la superficie

  const RayHit({
    required this.distance,
    required this.px,
    required this.py,
    required this.pz,
    required this.nx,
    required this.ny,
    required this.nz,
  });
}

/// Axis-Aligned Bounding Box.
class BBox3D {
  final double minX, minY, minZ;
  final double maxX, maxY, maxZ;

  const BBox3D({
    required this.minX,
    required this.minY,
    required this.minZ,
    required this.maxX,
    required this.maxY,
    required this.maxZ,
  });

  double get width => maxX - minX;
  double get height => maxY - minY;
  double get depth => maxZ - minZ;
}

// ============================================================================
// Context3D — API de alto nivel
// ============================================================================

class Context3D {
  final Graphics3D _g3d = Graphics3D();
  final Camera3DData camera = Camera3DData();

  // --------------------------------------------------------------------------
  // Cámara
  // --------------------------------------------------------------------------

  void beginMode() {
    _g3d.beginMode(
      camera.posX,
      camera.posY,
      camera.posZ,
      camera.targetX,
      camera.targetY,
      camera.targetZ,
      camera.upX,
      camera.upY,
      camera.upZ,
      camera.fovy,
      camera.projection,
    );
  }

  void endMode() => _g3d.endMode();

  /// Deja que Raylib actualice la cámara automáticamente con el [mode] indicado.
  /// Modifica [camera.posX/Y/Z] y [camera.targetX/Y/Z] en función del input actual.
  ///
  /// Modos disponibles: [CameraMode.free], [CameraMode.orbital],
  /// [CameraMode.firstPerson], [CameraMode.thirdPerson].
  void updateCamera([int mode = CameraMode.orbital]) {
    final r = _g3d.cameraUpdate(
      mode,
      camera.posX,
      camera.posY,
      camera.posZ,
      camera.targetX,
      camera.targetY,
      camera.targetZ,
      camera.upX,
      camera.upY,
      camera.upZ,
      camera.fovy,
      camera.projection,
    );
    camera.posX = r.$1;
    camera.posY = r.$2;
    camera.posZ = r.$3;
    camera.targetX = r.$4;
    camera.targetY = r.$5;
    camera.targetZ = r.$6;
  }

  // --------------------------------------------------------------------------
  // Primitivas (B1)
  // --------------------------------------------------------------------------

  void drawGrid([int slices = 20, double spacing = 1.0]) =>
      _g3d.drawGrid(slices, spacing);

  void drawBox(
    double x,
    double y,
    double z,
    double w,
    double h,
    double d, [
    ColorRGBA color = ColorRGBA.accentBlue,
    ColorRGBA? edgeColor,
  ]) {
    _g3d.drawBox(x, y, z, w, h, d, color.r, color.g, color.b, color.a);
    if (edgeColor != null) {
      _g3d.drawBoxWires(
        x,
        y,
        z,
        w,
        h,
        d,
        edgeColor.r,
        edgeColor.g,
        edgeColor.b,
        edgeColor.a,
      );
    }
  }

  void drawBoxWires(
    double x,
    double y,
    double z,
    double w,
    double h,
    double d, [
    ColorRGBA color = ColorRGBA.white,
  ]) => _g3d.drawBoxWires(x, y, z, w, h, d, color.r, color.g, color.b, color.a);

  void drawLine3D(
    double sx,
    double sy,
    double sz,
    double ex,
    double ey,
    double ez, [
    ColorRGBA color = ColorRGBA.white,
  ]) => _g3d.drawLine3D(
    sx,
    sy,
    sz,
    ex,
    ey,
    ez,
    color.r,
    color.g,
    color.b,
    color.a,
  );

  void drawAxes([double length = 5.0]) {
    const t = 0.04;
    drawBox(length / 2, 0, 0, length, t, t, const ColorRGBA(239, 68, 68));
    drawBox(0, length / 2, 0, t, length, t, const ColorRGBA(34, 197, 94));
    drawBox(0, 0, length / 2, t, t, length, const ColorRGBA(59, 130, 246));
  }

  /// Dibuja una esfera sólida. Pasa [wireColor] para superponer wireframe.
  void drawSphere(
    double x,
    double y,
    double z,
    double radius, {
    ColorRGBA color = ColorRGBA.accentBlue,
    ColorRGBA? wireColor,
    int rings = 16,
    int slices = 16,
  }) {
    _g3d.drawSphereEx(
      x,
      y,
      z,
      radius,
      rings,
      slices,
      color.r,
      color.g,
      color.b,
      color.a,
    );
    if (wireColor != null) {
      _g3d.drawSphereWires(
        x,
        y,
        z,
        radius,
        rings,
        slices,
        wireColor.r,
        wireColor.g,
        wireColor.b,
        wireColor.a,
      );
    }
  }

  void drawSphereWires(
    double x,
    double y,
    double z,
    double radius, {
    ColorRGBA color = ColorRGBA.white,
    int rings = 16,
    int slices = 16,
  }) => _g3d.drawSphereWires(
    x,
    y,
    z,
    radius,
    rings,
    slices,
    color.r,
    color.g,
    color.b,
    color.a,
  );

  /// Dibuja un cilindro de radio uniforme.
  void drawCylinder(
    double x,
    double y,
    double z,
    double radius,
    double height, {
    int slices = 16,
    ColorRGBA color = ColorRGBA.accentBlue,
    ColorRGBA? wireColor,
  }) {
    _g3d.drawCylinder(
      x,
      y,
      z,
      radius,
      height,
      slices,
      color.r,
      color.g,
      color.b,
      color.a,
    );
    if (wireColor != null) {
      _g3d.drawCylinderWires(
        x,
        y,
        z,
        radius,
        height,
        slices,
        wireColor.r,
        wireColor.g,
        wireColor.b,
        wireColor.a,
      );
    }
  }

  /// Dibuja un tronco cónico entre dos puntos. [radiusStart]=0 crea un cono.
  void drawCylinderEx(
    double sx,
    double sy,
    double sz,
    double ex,
    double ey,
    double ez,
    double radiusStart,
    double radiusEnd, {
    int slices = 16,
    ColorRGBA color = ColorRGBA.accentBlue,
    ColorRGBA? wireColor,
  }) {
    _g3d.drawCylinderEx(
      sx,
      sy,
      sz,
      ex,
      ey,
      ez,
      radiusStart,
      radiusEnd,
      slices,
      color.r,
      color.g,
      color.b,
      color.a,
    );
    if (wireColor != null) {
      _g3d.drawCylinderWiresEx(
        sx,
        sy,
        sz,
        ex,
        ey,
        ez,
        radiusStart,
        radiusEnd,
        slices,
        wireColor.r,
        wireColor.g,
        wireColor.b,
        wireColor.a,
      );
    }
  }

  /// Dibuja un plano horizontal centrado en (x, y, z).
  void drawPlane(
    double x,
    double y,
    double z,
    double width,
    double length, [
    ColorRGBA color = ColorRGBA.darkGray,
  ]) => _g3d.drawPlane(
    x,
    y,
    z,
    width,
    length,
    color.r,
    color.g,
    color.b,
    color.a,
  );

  // --------------------------------------------------------------------------
  // Modelos (B2)
  // --------------------------------------------------------------------------

  /// Carga un modelo 3D desde [path] (.obj, .gltf, .glb, etc.).
  /// Devuelve el handle (> 0) o 0 si falla.
  int loadModel(String path) => _g3d.modelLoad(path);

  /// Libera la GPU y elimina el handle del modelo.
  void unloadModel(int id) => _g3d.modelUnload(id);

  /// Dibuja el modelo con escala uniforme.
  void drawModel(
    int id,
    double x,
    double y,
    double z, {
    double scale = 1.0,
    ColorRGBA tint = ColorRGBA.white,
    bool wireframe = false,
  }) {
    if (wireframe) {
      _g3d.modelDrawWires(id, x, y, z, scale, tint.r, tint.g, tint.b, tint.a);
    } else {
      _g3d.modelDraw(id, x, y, z, scale, tint.r, tint.g, tint.b, tint.a);
    }
  }

  /// Dibuja el modelo con rotación ([angle] en grados, [axis] define el eje)
  /// y escala no uniforme.
  void drawModelEx(
    int id,
    double x,
    double y,
    double z, {
    double axisX = 0,
    double axisY = 1,
    double axisZ = 0,
    double angle = 0,
    double scaleX = 1,
    double scaleY = 1,
    double scaleZ = 1,
    ColorRGBA tint = ColorRGBA.white,
  }) => _g3d.modelDrawEx(
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
    tint.r,
    tint.g,
    tint.b,
    tint.a,
  );

  // --------------------------------------------------------------------------
  // Mallas Procedurales (F1)
  // --------------------------------------------------------------------------

  /// Genera un cubo procedural y lo devuelve como un modelo.
  int genModelCube(double width, double height, double length) =>
      _g3d.modelGenCube(width, height, length);

  /// Genera una esfera procedural y la devuelve como un modelo.
  int genModelSphere(double radius, int rings, int slices) =>
      _g3d.modelGenSphere(radius, rings, slices);

  /// Genera un cilindro procedural y lo devuelve como un modelo.
  int genModelCylinder(double radius, double height, int slices) =>
      _g3d.modelGenCylinder(radius, height, slices);

  /// Genera un cono procedural y lo devuelve como un modelo.
  int genModelCone(double radius, double height, int slices) =>
      _g3d.modelGenCone(radius, height, slices);

  /// Genera un plano procedural (suelo) y lo devuelve como un modelo.
  int genModelPlane(double width, double length, int resX, int resZ) =>
      _g3d.modelGenPlane(width, length, resX, resZ);

  // --------------------------------------------------------------------------
  // Picking / Ray casting (B3 & F4)
  // --------------------------------------------------------------------------

  /// Genera un rayo desde la posición [mouseX, mouseY] en pantalla hacia el mundo 3D,
  /// usando la cámara actual del contexto.
  Ray3D getMouseRay(double mouseX, double mouseY) {
    final r = _g3d.getMouseRay(
      mouseX,
      mouseY,
      camera.posX,
      camera.posY,
      camera.posZ,
      camera.targetX,
      camera.targetY,
      camera.targetZ,
      camera.upX,
      camera.upY,
      camera.upZ,
      camera.fovy,
      camera.projection,
    );
    return Ray3D(ox: r.$1, oy: r.$2, oz: r.$3, dx: r.$4, dy: r.$5, dz: r.$6);
  }

  /// Comprueba si [ray] intersecta con el AABB dado. Devuelve null si no hay colisión.
  RayHit? rayHitsBox(Ray3D ray, BBox3D box) {
    final r = _g3d.rayHitsBox(
      ray.ox,
      ray.oy,
      ray.oz,
      ray.dx,
      ray.dy,
      ray.dz,
      box.minX,
      box.minY,
      box.minZ,
      box.maxX,
      box.maxY,
      box.maxZ,
    );
    if (r == null) return null;
    return RayHit(
      distance: r.dist,
      px: r.px,
      py: r.py,
      pz: r.pz,
      nx: r.nx,
      ny: r.ny,
      nz: r.nz,
    );
  }

  /// Comprueba si el [ray] intersecta con una malla específica [meshIndex] de un [modelId].
  /// Requiere la matriz de transformación (16 floats) del modelo en el mundo.
  RayHit? rayHitsModelMesh(
    Ray3D ray,
    int modelId,
    int meshIndex,
    List<double> transform,
  ) {
    assert(
      transform.length == 16,
      'La matriz de transformación debe tener 16 elementos',
    );
    final r = _g3d.rayHitsModelMesh(
      ray.ox,
      ray.oy,
      ray.oz,
      ray.dx,
      ray.dy,
      ray.dz,
      modelId,
      meshIndex,
      transform[0],
      transform[1],
      transform[2],
      transform[3],
      transform[4],
      transform[5],
      transform[6],
      transform[7],
      transform[8],
      transform[9],
      transform[10],
      transform[11],
      transform[12],
      transform[13],
      transform[14],
      transform[15],
    );
    if (r == null) return null;
    return RayHit(
      distance: r.dist,
      px: r.px,
      py: r.py,
      pz: r.pz,
      nx: r.nx,
      ny: r.ny,
      nz: r.nz,
    );
  }

  // --------------------------------------------------------------------------
  // BoundingBox (B4)
  // --------------------------------------------------------------------------

  /// Visualiza un AABB como wireframe.
  void drawBoundingBox(BBox3D box, [ColorRGBA color = ColorRGBA.white]) =>
      _g3d.drawBbox(
        box.minX,
        box.minY,
        box.minZ,
        box.maxX,
        box.maxY,
        box.maxZ,
        color.r,
        color.g,
        color.b,
        color.a,
      );

  /// Obtiene el AABB del modelo cargado. Devuelve null si el ID no existe.
  BBox3D? getModelBoundingBox(int id) {
    final r = _g3d.modelGetBbox(id);
    if (r == null) return null;
    return BBox3D(
      minX: r.$1,
      minY: r.$2,
      minZ: r.$3,
      maxX: r.$4,
      maxY: r.$5,
      maxZ: r.$6,
    );
  }

  // --------------------------------------------------------------------------
  // Shaders (B5)
  // --------------------------------------------------------------------------

  /// Carga un shader desde archivos GLSL en disco.
  /// Pasa null en alguno de los parámetros para usar el shader por defecto de Raylib.
  int loadShader({String? vsPath, String? fsPath}) =>
      _g3d.shaderLoad(vsPath, fsPath);

  /// Carga un shader desde código GLSL en memoria.
  int loadShaderFromMemory({String? vsCode, String? fsCode}) =>
      _g3d.shaderLoadFromMemory(vsCode, fsCode);

  void unloadShader(int id) => _g3d.shaderUnload(id);

  /// Activa el shader. Todas las llamadas de dibujo siguientes lo usarán.
  /// Llama a [endShader()] para restaurar el pipeline por defecto.
  void beginShader(int id) => _g3d.shaderBegin(id);
  void endShader() => _g3d.shaderEnd();

  /// Obtiene la localización de un uniform por nombre. Devuelve -1 si no existe.
  int getUniformLocation(int shaderId, String name) =>
      _g3d.shaderGetLocation(shaderId, name);

  void setUniformFloat(int shaderId, int loc, double value) =>
      _g3d.shaderSetFloat(shaderId, loc, value);
  void setUniformVec2(int shaderId, int loc, double x, double y) =>
      _g3d.shaderSetVec2(shaderId, loc, x, y);
  void setUniformVec3(int shaderId, int loc, double x, double y, double z) =>
      _g3d.shaderSetVec3(shaderId, loc, x, y, z);
  void setUniformVec4(
    int shaderId,
    int loc,
    double x,
    double y,
    double z,
    double w,
  ) => _g3d.shaderSetVec4(shaderId, loc, x, y, z, w);
  void setUniformInt(int shaderId, int loc, int value) =>
      _g3d.shaderSetInt(shaderId, loc, value);

  /// Asigna una textura (por su ID de `g2d_load_texture`) a un sampler2D uniform.
  void setUniformTexture(int shaderId, int loc, int textureId) =>
      _g3d.shaderSetTexture(shaderId, loc, textureId);
  void setUniformMatrix(int shaderId, int loc, List<double> m) {
    assert(m.length == 16, 'La matriz debe tener 16 elementos (4x4)');
    _g3d.shaderSetMatrix(
      shaderId,
      loc,
      m[0],
      m[1],
      m[2],
      m[3],
      m[4],
      m[5],
      m[6],
      m[7],
      m[8],
      m[9],
      m[10],
      m[11],
      m[12],
      m[13],
      m[14],
      m[15],
    );
  }

  // --------------------------------------------------------------------------
  // Materiales (B6)
  // --------------------------------------------------------------------------

  /// Asigna una textura al slot [mapType] del material [materialIndex] del modelo.
  /// Usa las constantes de [MaterialMap] para [mapType].
  bool setModelTexture(
    int modelId,
    int textureId, {
    int materialIndex = 0,
    int mapType = MaterialMap.albedo,
  }) =>
      _g3d.modelSetMaterialTexture(modelId, materialIndex, mapType, textureId);

  /// Número de materiales del modelo. Devuelve -1 si el modelo no existe.
  int getModelMaterialCount(int modelId) => _g3d.modelMaterialCount(modelId);

  /// Número de meshes del modelo. Devuelve -1 si el modelo no existe.
  int getModelMeshCount(int modelId) => _g3d.modelMeshCount(modelId);

  // --------------------------------------------------------------------------
  // Animaciones (B7)
  // --------------------------------------------------------------------------

  /// Carga animaciones desde un archivo (.glb, .iqm, etc.).
  /// Devuelve (animSetId, count). Si falla, animSetId = 0.
  (int animSetId, int count) loadAnimations(String path) => _g3d.animLoad(path);

  /// Libera un conjunto de animaciones.
  void unloadAnimations(int animSetId) => _g3d.animUnload(animSetId);

  /// Número de animaciones en el conjunto.
  int animationCount(int animSetId) => _g3d.animCount(animSetId);

  /// Número de frames (keyframes) de la animación [animIndex].
  int animationFrameCount(int animSetId, int animIndex) =>
      _g3d.animFrameCount(animSetId, animIndex);

  /// Aplica el [frame] de la animación [animIndex] al modelo [modelId].
  /// [frame] puede ser fraccionario para interpolación suave.
  /// Devuelve true si fue exitoso.
  bool updateAnimation(
    int modelId,
    int animSetId,
    int animIndex,
    double frame,
  ) => _g3d.animUpdate(modelId, animSetId, animIndex, frame);

  /// Comprueba si la animación es compatible con el modelo.
  bool isAnimationValid(int modelId, int animSetId, int animIndex) =>
      _g3d.animIsValid(modelId, animSetId, animIndex);
}
