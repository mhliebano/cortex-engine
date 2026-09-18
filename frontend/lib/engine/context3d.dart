import 'package:cortex/graphics3d.dart';
import 'package:cortex/engine/context2d.dart';

class CameraProjection {
  static const int perspective = 0;
  static const int orthographic = 1;
}

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

class Context3D {
  final Graphics3D _g3d = Graphics3D();
  final Camera3DData camera = Camera3DData();

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

  void endMode() {
    _g3d.endMode();
  }

  void drawGrid([int slices = 20, double spacing = 1.0]) {
    _g3d.drawGrid(slices, spacing);
  }

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
      _g3d.drawBoxWires(x, y, z, w, h, d, edgeColor.r, edgeColor.g, edgeColor.b, edgeColor.a);
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
  ]) {
    _g3d.drawBoxWires(x, y, z, w, h, d, color.r, color.g, color.b, color.a);
  }

  void drawLine3D(
    double startX,
    double startY,
    double startZ,
    double endX,
    double endY,
    double endZ, [
    ColorRGBA color = ColorRGBA.white,
  ]) {
    _g3d.drawLine3D(startX, startY, startZ, endX, endY, endZ, color.r, color.g, color.b, color.a);
  }

  void drawAxes([double length = 5.0]) {
    const thickness = 0.04;
    // X Axis (Rojo)
    drawBox(length / 2, 0, 0, length, thickness, thickness, const ColorRGBA(239, 68, 68));
    // Y Axis (Verde)
    drawBox(0, length / 2, 0, thickness, length, thickness, const ColorRGBA(34, 197, 94));
    // Z Axis (Azul)
    drawBox(0, 0, length / 2, thickness, thickness, length, const ColorRGBA(59, 130, 246));
  }
}
