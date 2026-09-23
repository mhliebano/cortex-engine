import 'dart:ffi' as ffi;

// ============================================================================
// Tipos existentes (B1: cámara + primitivas)
// ============================================================================

typedef G3dBeginModeC = ffi.Void Function(
  ffi.Float cx, ffi.Float cy, ffi.Float cz,
  ffi.Float tx, ffi.Float ty, ffi.Float tz,
  ffi.Float upX, ffi.Float upY, ffi.Float upZ,
  ffi.Float fovy, ffi.Int32 projection,
);
typedef G3dBeginMode = void Function(
  double cx, double cy, double cz,
  double tx, double ty, double tz,
  double upX, double upY, double upZ,
  double fovy, int projection,
);

typedef G3dVoidActionC = ffi.Void Function();
typedef G3dVoidAction = void Function();

typedef G3dDrawGridC = ffi.Void Function(ffi.Int32 slices, ffi.Float spacing);
typedef G3dDrawGrid = void Function(int slices, double spacing);

typedef G3dDrawBoxC = ffi.Void Function(
  ffi.Float x, ffi.Float y, ffi.Float z,
  ffi.Float w, ffi.Float h, ffi.Float d,
  ffi.Uint8 r, ffi.Uint8 g, ffi.Uint8 b, ffi.Uint8 a,
);
typedef G3dDrawBox = void Function(
  double x, double y, double z,
  double w, double h, double d,
  int r, int g, int b, int a,
);

typedef G3dDrawLine3DC = ffi.Void Function(
  ffi.Float startX, ffi.Float startY, ffi.Float startZ,
  ffi.Float endX, ffi.Float endY, ffi.Float endZ,
  ffi.Uint8 r, ffi.Uint8 g, ffi.Uint8 b, ffi.Uint8 a,
);
typedef G3dDrawLine3D = void Function(
  double startX, double startY, double startZ,
  double endX, double endY, double endZ,
  int r, int g, int b, int a,
);

// Esfera
typedef G3dDrawSphereC = ffi.Void Function(
  ffi.Float x, ffi.Float y, ffi.Float z, ffi.Float radius,
  ffi.Uint8 r, ffi.Uint8 g, ffi.Uint8 b, ffi.Uint8 a,
);
typedef G3dDrawSphere = void Function(
  double x, double y, double z, double radius,
  int r, int g, int b, int a,
);

typedef G3dDrawSphereExC = ffi.Void Function(
  ffi.Float x, ffi.Float y, ffi.Float z, ffi.Float radius,
  ffi.Int32 rings, ffi.Int32 slices,
  ffi.Uint8 r, ffi.Uint8 g, ffi.Uint8 b, ffi.Uint8 a,
);
typedef G3dDrawSphereEx = void Function(
  double x, double y, double z, double radius,
  int rings, int slices,
  int r, int g, int b, int a,
);

// Cilindro
typedef G3dDrawCylinderC = ffi.Void Function(
  ffi.Float x, ffi.Float y, ffi.Float z,
  ffi.Float radius, ffi.Float height, ffi.Int32 slices,
  ffi.Uint8 r, ffi.Uint8 g, ffi.Uint8 b, ffi.Uint8 a,
);
typedef G3dDrawCylinder = void Function(
  double x, double y, double z,
  double radius, double height, int slices,
  int r, int g, int b, int a,
);

typedef G3dDrawCylinderExC = ffi.Void Function(
  ffi.Float startX, ffi.Float startY, ffi.Float startZ,
  ffi.Float endX, ffi.Float endY, ffi.Float endZ,
  ffi.Float radiusStart, ffi.Float radiusEnd, ffi.Int32 slices,
  ffi.Uint8 r, ffi.Uint8 g, ffi.Uint8 b, ffi.Uint8 a,
);
typedef G3dDrawCylinderEx = void Function(
  double startX, double startY, double startZ,
  double endX, double endY, double endZ,
  double radiusStart, double radiusEnd, int slices,
  int r, int g, int b, int a,
);

// Plano
typedef G3dDrawPlaneC = ffi.Void Function(
  ffi.Float x, ffi.Float y, ffi.Float z,
  ffi.Float width, ffi.Float length,
  ffi.Uint8 r, ffi.Uint8 g, ffi.Uint8 b, ffi.Uint8 a,
);
typedef G3dDrawPlane = void Function(
  double x, double y, double z,
  double width, double length,
  int r, int g, int b, int a,
);

// ============================================================================
// B2: Modelos
// ============================================================================

typedef G3dModelLoadC = ffi.Int32 Function(ffi.Pointer<ffi.Char> path);
typedef G3dModelLoad = int Function(ffi.Pointer<ffi.Char> path);

typedef G3dModelIntActionC = ffi.Void Function(ffi.Int32 id);
typedef G3dModelIntAction = void Function(int id);

typedef G3dModelDrawC = ffi.Void Function(
  ffi.Int32 id,
  ffi.Float x, ffi.Float y, ffi.Float z,
  ffi.Float scale,
  ffi.Uint8 r, ffi.Uint8 g, ffi.Uint8 b, ffi.Uint8 a,
);
typedef G3dModelDraw = void Function(
  int id,
  double x, double y, double z,
  double scale,
  int r, int g, int b, int a,
);

typedef G3dModelDrawExC = ffi.Void Function(
  ffi.Int32 id,
  ffi.Float x, ffi.Float y, ffi.Float z,
  ffi.Float axisX, ffi.Float axisY, ffi.Float axisZ,
  ffi.Float angle,
  ffi.Float scaleX, ffi.Float scaleY, ffi.Float scaleZ,
  ffi.Uint8 r, ffi.Uint8 g, ffi.Uint8 b, ffi.Uint8 a,
);
typedef G3dModelDrawEx = void Function(
  int id,
  double x, double y, double z,
  double axisX, double axisY, double axisZ,
  double angle,
  double scaleX, double scaleY, double scaleZ,
  int r, int g, int b, int a,
);

// ============================================================================
// F1: Mallas procedurales
// ============================================================================

typedef G3dModelGenCubeC = ffi.Int32 Function(ffi.Float w, ffi.Float h, ffi.Float l);
typedef G3dModelGenCube = int Function(double w, double h, double l);

typedef G3dModelGenSphereC = ffi.Int32 Function(ffi.Float r, ffi.Int32 rings, ffi.Int32 slices);
typedef G3dModelGenSphere = int Function(double r, int rings, int slices);

typedef G3dModelGenCylinderC = ffi.Int32 Function(ffi.Float r, ffi.Float h, ffi.Int32 slices);
typedef G3dModelGenCylinder = int Function(double r, double h, int slices);

typedef G3dModelGenConeC = ffi.Int32 Function(ffi.Float r, ffi.Float h, ffi.Int32 slices);
typedef G3dModelGenCone = int Function(double r, double h, int slices);

typedef G3dModelGenPlaneC = ffi.Int32 Function(ffi.Float w, ffi.Float l, ffi.Int32 resX, ffi.Int32 resZ);
typedef G3dModelGenPlane = int Function(double w, double l, int resX, int resZ);

// ============================================================================
// B3: Picking / Ray casting
// ============================================================================

typedef G3dGetMouseRayC = ffi.Void Function(
  ffi.Float mouseX, ffi.Float mouseY,
  ffi.Float camX, ffi.Float camY, ffi.Float camZ,
  ffi.Float targetX, ffi.Float targetY, ffi.Float targetZ,
  ffi.Float upX, ffi.Float upY, ffi.Float upZ,
  ffi.Float fovy, ffi.Int32 projection,
  ffi.Pointer<ffi.Float> ox, ffi.Pointer<ffi.Float> oy, ffi.Pointer<ffi.Float> oz,
  ffi.Pointer<ffi.Float> dx, ffi.Pointer<ffi.Float> dy, ffi.Pointer<ffi.Float> dz,
);
typedef G3dGetMouseRay = void Function(
  double mouseX, double mouseY,
  double camX, double camY, double camZ,
  double targetX, double targetY, double targetZ,
  double upX, double upY, double upZ,
  double fovy, int projection,
  ffi.Pointer<ffi.Float> ox, ffi.Pointer<ffi.Float> oy, ffi.Pointer<ffi.Float> oz,
  ffi.Pointer<ffi.Float> dx, ffi.Pointer<ffi.Float> dy, ffi.Pointer<ffi.Float> dz,
);

typedef G3dRayHitsBoxC = ffi.Int32 Function(
  ffi.Float rox, ffi.Float roy, ffi.Float roz,
  ffi.Float rdx, ffi.Float rdy, ffi.Float rdz,
  ffi.Float bmnx, ffi.Float bmny, ffi.Float bmnz,
  ffi.Float bmxx, ffi.Float bmxy, ffi.Float bmxz,
  ffi.Pointer<ffi.Float> dist,
  ffi.Pointer<ffi.Float> px, ffi.Pointer<ffi.Float> py, ffi.Pointer<ffi.Float> pz,
  ffi.Pointer<ffi.Float> nx, ffi.Pointer<ffi.Float> ny, ffi.Pointer<ffi.Float> nz,
);
typedef G3dRayHitsBox = int Function(
  double rox, double roy, double roz,
  double rdx, double rdy, double rdz,
  double bmnx, double bmny, double bmnz,
  double bmxx, double bmxy, double bmxz,
  ffi.Pointer<ffi.Float> dist,
  ffi.Pointer<ffi.Float> px, ffi.Pointer<ffi.Float> py, ffi.Pointer<ffi.Float> pz,
  ffi.Pointer<ffi.Float> nx, ffi.Pointer<ffi.Float> ny, ffi.Pointer<ffi.Float> nz,
);

typedef G3dRayHitsModelMeshC = ffi.Int32 Function(
  ffi.Float rox, ffi.Float roy, ffi.Float roz,
  ffi.Float rdx, ffi.Float rdy, ffi.Float rdz,
  ffi.Int32 modelId, ffi.Int32 meshIndex,
  ffi.Float m0, ffi.Float m1, ffi.Float m2, ffi.Float m3,
  ffi.Float m4, ffi.Float m5, ffi.Float m6, ffi.Float m7,
  ffi.Float m8, ffi.Float m9, ffi.Float m10, ffi.Float m11,
  ffi.Float m12, ffi.Float m13, ffi.Float m14, ffi.Float m15,
  ffi.Pointer<ffi.Float> dist,
  ffi.Pointer<ffi.Float> px, ffi.Pointer<ffi.Float> py, ffi.Pointer<ffi.Float> pz,
  ffi.Pointer<ffi.Float> nx, ffi.Pointer<ffi.Float> ny, ffi.Pointer<ffi.Float> nz,
);
typedef G3dRayHitsModelMesh = int Function(
  double rox, double roy, double roz,
  double rdx, double rdy, double rdz,
  int modelId, int meshIndex,
  double m0, double m1, double m2, double m3,
  double m4, double m5, double m6, double m7,
  double m8, double m9, double m10, double m11,
  double m12, double m13, double m14, double m15,
  ffi.Pointer<ffi.Float> dist,
  ffi.Pointer<ffi.Float> px, ffi.Pointer<ffi.Float> py, ffi.Pointer<ffi.Float> pz,
  ffi.Pointer<ffi.Float> nx, ffi.Pointer<ffi.Float> ny, ffi.Pointer<ffi.Float> nz,
);

// ============================================================================
// B4: BoundingBox
// ============================================================================

typedef G3dDrawBboxC = ffi.Void Function(
  ffi.Float minX, ffi.Float minY, ffi.Float minZ,
  ffi.Float maxX, ffi.Float maxY, ffi.Float maxZ,
  ffi.Uint8 r, ffi.Uint8 g, ffi.Uint8 b, ffi.Uint8 a,
);
typedef G3dDrawBbox = void Function(
  double minX, double minY, double minZ,
  double maxX, double maxY, double maxZ,
  int r, int g, int b, int a,
);

typedef G3dModelGetBboxC = ffi.Int32 Function(
  ffi.Int32 id,
  ffi.Pointer<ffi.Float> minX, ffi.Pointer<ffi.Float> minY, ffi.Pointer<ffi.Float> minZ,
  ffi.Pointer<ffi.Float> maxX, ffi.Pointer<ffi.Float> maxY, ffi.Pointer<ffi.Float> maxZ,
);
typedef G3dModelGetBbox = int Function(
  int id,
  ffi.Pointer<ffi.Float> minX, ffi.Pointer<ffi.Float> minY, ffi.Pointer<ffi.Float> minZ,
  ffi.Pointer<ffi.Float> maxX, ffi.Pointer<ffi.Float> maxY, ffi.Pointer<ffi.Float> maxZ,
);

// ============================================================================
// B5: Shaders
// ============================================================================

typedef G3dShaderLoadC = ffi.Int32 Function(
  ffi.Pointer<ffi.Char> vsPath, ffi.Pointer<ffi.Char> fsPath,
);
typedef G3dShaderLoad = int Function(
  ffi.Pointer<ffi.Char> vsPath, ffi.Pointer<ffi.Char> fsPath,
);

typedef G3dShaderIntActionC = ffi.Void Function(ffi.Int32 id);
typedef G3dShaderIntAction = void Function(int id);

typedef G3dShaderGetLocationC = ffi.Int32 Function(
  ffi.Int32 id, ffi.Pointer<ffi.Char> name,
);
typedef G3dShaderGetLocation = int Function(
  int id, ffi.Pointer<ffi.Char> name,
);

typedef G3dShaderSetFloatC = ffi.Void Function(
  ffi.Int32 id, ffi.Int32 loc, ffi.Float value,
);
typedef G3dShaderSetFloat = void Function(int id, int loc, double value);

typedef G3dShaderSetVec2C = ffi.Void Function(
  ffi.Int32 id, ffi.Int32 loc, ffi.Float x, ffi.Float y,
);
typedef G3dShaderSetVec2 = void Function(int id, int loc, double x, double y);

typedef G3dShaderSetVec3C = ffi.Void Function(
  ffi.Int32 id, ffi.Int32 loc, ffi.Float x, ffi.Float y, ffi.Float z,
);
typedef G3dShaderSetVec3 = void Function(
  int id, int loc, double x, double y, double z,
);

typedef G3dShaderSetVec4C = ffi.Void Function(
  ffi.Int32 id, ffi.Int32 loc,
  ffi.Float x, ffi.Float y, ffi.Float z, ffi.Float w,
);
typedef G3dShaderSetVec4 = void Function(
  int id, int loc, double x, double y, double z, double w,
);

typedef G3dShaderSetIntC = ffi.Void Function(
  ffi.Int32 id, ffi.Int32 loc, ffi.Int32 value,
);
typedef G3dShaderSetInt = void Function(int id, int loc, int value);

typedef G3dShaderSetTextureC = ffi.Void Function(
  ffi.Int32 shaderId, ffi.Int32 loc, ffi.Int32 textureId,
);
typedef G3dShaderSetTexture = void Function(
  int shaderId, int loc, int textureId,
);

typedef G3dShaderSetMatrixC = ffi.Void Function(
  ffi.Int32 id, ffi.Int32 loc,
  ffi.Float m0,  ffi.Float m1,  ffi.Float m2,  ffi.Float m3,
  ffi.Float m4,  ffi.Float m5,  ffi.Float m6,  ffi.Float m7,
  ffi.Float m8,  ffi.Float m9,  ffi.Float m10, ffi.Float m11,
  ffi.Float m12, ffi.Float m13, ffi.Float m14, ffi.Float m15,
);
typedef G3dShaderSetMatrix = void Function(
  int id, int loc,
  double m0,  double m1,  double m2,  double m3,
  double m4,  double m5,  double m6,  double m7,
  double m8,  double m9,  double m10, double m11,
  double m12, double m13, double m14, double m15,
);

// ============================================================================
// B6: Materiales
// ============================================================================

typedef G3dModelSetMaterialTextureC = ffi.Int32 Function(
  ffi.Int32 modelId, ffi.Int32 materialIndex, ffi.Int32 mapType, ffi.Int32 textureId,
);
typedef G3dModelSetMaterialTexture = int Function(
  int modelId, int materialIndex, int mapType, int textureId,
);

typedef G3dModelIntQueryC = ffi.Int32 Function(ffi.Int32 id);
typedef G3dModelIntQuery = int Function(int id);

// ============================================================================
// B7: Animaciones
// ============================================================================

typedef G3dAnimLoadC = ffi.Int32 Function(
  ffi.Pointer<ffi.Char> path, ffi.Pointer<ffi.Int32> outCount,
);
typedef G3dAnimLoad = int Function(
  ffi.Pointer<ffi.Char> path, ffi.Pointer<ffi.Int32> outCount,
);

typedef G3dAnimSetIntC = ffi.Void Function(ffi.Int32 animSetId);
typedef G3dAnimSetInt = void Function(int animSetId);

typedef G3dAnimSetIntQueryC = ffi.Int32 Function(ffi.Int32 animSetId);
typedef G3dAnimSetIntQuery = int Function(int animSetId);

typedef G3dAnimFrameCountC = ffi.Int32 Function(
  ffi.Int32 animSetId, ffi.Int32 animIndex,
);
typedef G3dAnimFrameCount = int Function(int animSetId, int animIndex);

typedef G3dAnimUpdateC = ffi.Int32 Function(
  ffi.Int32 modelId, ffi.Int32 animSetId, ffi.Int32 animIndex, ffi.Float frame,
);
typedef G3dAnimUpdate = int Function(
  int modelId, int animSetId, int animIndex, double frame,
);

typedef G3dAnimIsValidC = ffi.Int32 Function(
  ffi.Int32 modelId, ffi.Int32 animSetId, ffi.Int32 animIndex,
);
typedef G3dAnimIsValid = int Function(
  int modelId, int animSetId, int animIndex,
);

// ============================================================================
// B8: Cámara orbital
// ============================================================================

typedef G3dCameraUpdateC = ffi.Void Function(
  ffi.Int32 mode,
  ffi.Float camX, ffi.Float camY, ffi.Float camZ,
  ffi.Float targetX, ffi.Float targetY, ffi.Float targetZ,
  ffi.Float upX, ffi.Float upY, ffi.Float upZ,
  ffi.Float fovy, ffi.Int32 projection,
  ffi.Pointer<ffi.Float> outCamX, ffi.Pointer<ffi.Float> outCamY, ffi.Pointer<ffi.Float> outCamZ,
  ffi.Pointer<ffi.Float> outTargetX, ffi.Pointer<ffi.Float> outTargetY, ffi.Pointer<ffi.Float> outTargetZ,
);
typedef G3dCameraUpdate = void Function(
  int mode,
  double camX, double camY, double camZ,
  double targetX, double targetY, double targetZ,
  double upX, double upY, double upZ,
  double fovy, int projection,
  ffi.Pointer<ffi.Float> outCamX, ffi.Pointer<ffi.Float> outCamY, ffi.Pointer<ffi.Float> outCamZ,
  ffi.Pointer<ffi.Float> outTargetX, ffi.Pointer<ffi.Float> outTargetY, ffi.Pointer<ffi.Float> outTargetZ,
);
