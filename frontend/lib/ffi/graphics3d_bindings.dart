import 'dart:ffi' as ffi;

typedef G3dBeginModeC =
    ffi.Void Function(
      ffi.Float cx,
      ffi.Float cy,
      ffi.Float cz,
      ffi.Float tx,
      ffi.Float ty,
      ffi.Float tz,
      ffi.Float upX,
      ffi.Float upY,
      ffi.Float upZ,
      ffi.Float fovy,
      ffi.Int32 projection,
    );
typedef G3dBeginMode =
    void Function(
      double cx,
      double cy,
      double cz,
      double tx,
      double ty,
      double tz,
      double upX,
      double upY,
      double upZ,
      double fovy,
      int projection,
    );

typedef G3dVoidActionC = ffi.Void Function();
typedef G3dVoidAction = void Function();

typedef G3dDrawGridC = ffi.Void Function(ffi.Int32 slices, ffi.Float spacing);
typedef G3dDrawGrid = void Function(int slices, double spacing);

typedef G3dDrawBoxC =
    ffi.Void Function(
      ffi.Float x,
      ffi.Float y,
      ffi.Float z,
      ffi.Float w,
      ffi.Float h,
      ffi.Float d,
      ffi.Uint8 r,
      ffi.Uint8 g,
      ffi.Uint8 b,
      ffi.Uint8 a,
    );
typedef G3dDrawBox =
    void Function(
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
    );

typedef G3dDrawLine3DC =
    ffi.Void Function(
      ffi.Float startX,
      ffi.Float startY,
      ffi.Float startZ,
      ffi.Float endX,
      ffi.Float endY,
      ffi.Float endZ,
      ffi.Uint8 r,
      ffi.Uint8 g,
      ffi.Uint8 b,
      ffi.Uint8 a,
    );
typedef G3dDrawLine3D =
    void Function(
      double startX,
      double startY,
      double startZ,
      double endX,
      double endY,
      double endZ,
      int r,
      int g,
      int b,
      int a,
    );
