import 'dart:ffi';
import 'package:cortex/ffi/lib_loader.dart';
import 'ffi/graphics3d_bindings.dart';

class Graphics3D {
  late final G3dBeginMode _beginMode;
  late final G3dVoidAction _endMode;
  late final G3dDrawGrid _drawGrid;
  late final G3dDrawBox _drawBox;
  late final G3dDrawBox _drawBoxWires;
  late final G3dDrawLine3D _drawLine3D;

  Graphics3D() {
    final dylib = loadNativeLibrary();

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
    _drawBoxWires = dylib.lookupFunction<G3dDrawBoxC, G3dDrawBox>('g3d_draw_box_wires');
    _drawLine3D = dylib.lookupFunction<G3dDrawLine3DC, G3dDrawLine3D>('g3d_draw_line3d');
  }

  void beginMode(
    double cx,
    double cy,
    double cz, [
    double tx = 0.0,
    double ty = 0.0,
    double tz = 0.0,
    double upX = 0.0,
    double upY = 1.0,
    double upZ = 0.0,
    double fovy = 45.0,
    int projection = 0, // 0 = Perspective, 1 = Orthographic
  ]) {
    _beginMode(cx, cy, cz, tx, ty, tz, upX, upY, upZ, fovy, projection);
  }

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
  ) {
    _drawBox(x, y, z, w, h, d, r, g, b, a);
  }

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
  ) {
    _drawBoxWires(x, y, z, w, h, d, r, g, b, a);
  }

  void drawLine3D(
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
  ) {
    _drawLine3D(startX, startY, startZ, endX, endY, endZ, r, g, b, a);
  }
}
