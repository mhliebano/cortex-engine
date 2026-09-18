import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:cortex/ffi/lib_loader.dart';
import 'ffi/graphics2d_bindings.dart';

class Graphics2D {
  late final G2dLoadFont _loadFont;
  late final G2dLoadIconFont _loadIconFont;
  late final G2dDrawRect _drawRect;
  late final G2dDrawRect _drawRectLines;
  late final G2dDrawText _drawText;
  late final G2dDrawCircle _drawCircle;
  late final G2dDrawCircleLines _drawCircleLines;
  late final G2dDrawArc _drawArc;
  late final G2dDrawArcLines _drawArcLines;
  late final G2dLoadTexture _loadTexture;
  late final G2dDrawTexture _drawTexture;
  late final G2dGetTextureWidth _getTextureWidth;
  late final G2dGetTextureHeight _getTextureHeight;
  late final G2dUnloadTexture _unloadTexture;
  late final G2dDrawRoundRect _drawRoundRect;
  late final G2dDrawRoundRectLines _drawRoundRectLines;
  late final G2dDrawPoly _drawPoly;
  late final G2dDrawPolyLines _drawPolyLines;
  late final G2dDrawTriangle _drawTriangle;
  late final G2dDrawTriangleLines _drawTriangleLines;

  // Caché de punteros Utf8 para eliminar asignaciones/desasignaciones nativas en el render loop (60 FPS)
  final Map<String, Pointer<Utf8>> _stringCache = {};

  Graphics2D() {
    final dylib = loadNativeLibrary();

    _loadFont = dylib.lookupFunction<G2dLoadFontC, G2dLoadFont>(
      'g2d_load_font',
    );
    _loadIconFont = dylib.lookupFunction<G2dLoadIconFontC, G2dLoadIconFont>(
      'g2d_load_icon_font',
    );
    _drawRect = dylib.lookupFunction<G2dDrawRectC, G2dDrawRect>(
      'g2d_draw_rect',
    );
    _drawRectLines = dylib.lookupFunction<G2dDrawRectC, G2dDrawRect>(
      'g2d_draw_rect_lines',
    );
    _drawText = dylib.lookupFunction<G2dDrawTextC, G2dDrawText>(
      'g2d_draw_text',
    );
    _drawCircle = dylib.lookupFunction<G2dDrawCircleC, G2dDrawCircle>(
      'g2d_draw_circle',
    );
    _drawCircleLines = dylib
        .lookupFunction<G2dDrawCircleLinesC, G2dDrawCircleLines>(
          'g2d_draw_circle_lines',
        );
    _drawArc = dylib.lookupFunction<G2dDrawArcC, G2dDrawArc>('g2d_draw_arc');
    _drawArcLines = dylib.lookupFunction<G2dDrawArcLinesC, G2dDrawArcLines>(
      'g2d_draw_arc_lines',
    );
    _loadTexture = dylib.lookupFunction<G2dLoadTextureC, G2dLoadTexture>(
      'g2d_load_texture',
    );
    _drawTexture = dylib.lookupFunction<G2dDrawTextureC, G2dDrawTexture>(
      'g2d_draw_texture',
    );
    _getTextureWidth = dylib
        .lookupFunction<G2dGetTextureWidthC, G2dGetTextureWidth>(
          'g2d_get_texture_width',
        );
    _getTextureHeight = dylib
        .lookupFunction<G2dGetTextureHeightC, G2dGetTextureHeight>(
          'g2d_get_texture_height',
        );
    _unloadTexture = dylib.lookupFunction<G2dUnloadTextureC, G2dUnloadTexture>(
      'g2d_unload_texture',
    );
    _drawRoundRect = dylib.lookupFunction<G2dDrawRoundRectC, G2dDrawRoundRect>(
      'g2d_draw_round_rect',
    );
    _drawRoundRectLines = dylib
        .lookupFunction<G2dDrawRoundRectLinesC, G2dDrawRoundRectLines>(
          'g2d_draw_round_rect_lines',
        );
    _drawPoly = dylib.lookupFunction<G2dDrawPolyC, G2dDrawPoly>(
      'g2d_draw_poly',
    );
    _drawPolyLines = dylib.lookupFunction<G2dDrawPolyLinesC, G2dDrawPolyLines>(
      'g2d_draw_poly_lines',
    );
    _drawTriangle = dylib.lookupFunction<G2dDrawTriangleC, G2dDrawTriangle>(
      'g2d_draw_triangle',
    );
    _drawTriangleLines = dylib
        .lookupFunction<G2dDrawTriangleLinesC, G2dDrawTriangleLines>(
          'g2d_draw_triangle_lines',
        );
  }

  /// Carga una fuente nativa vectorizada TTF/OTF (ej. Inter, Liberation Sans, Roboto)
  /// con renderizado ultra-nítido y filtrado bilineal.
  bool loadFont(String filePath, [int fontSize = 32]) {
    final ptr = filePath.toNativeUtf8();
    final result = _loadFont(ptr, fontSize);
    calloc.free(ptr);
    return result != 0;
  }

  /// Carga una fuente de íconos vectorizada TTF (ej. Google Material Icons)
  /// con soporte para el rango de caracteres PUA (Private Use Area).
  bool loadIconFont(String filePath, [int fontSize = 32]) {
    final ptr = filePath.toNativeUtf8();
    final result = _loadIconFont(ptr, fontSize);
    calloc.free(ptr);
    return result != 0;
  }

  void drawRect(int x, int y, int w, int h, int r, int g, int b, int a) {
    _drawRect(x, y, w, h, r, g, b, a);
  }

  void drawRectLines(int x, int y, int w, int h, int r, int g, int b, int a) {
    _drawRectLines(x, y, w, h, r, g, b, a);
  }

  void drawText(
    String text,
    int x,
    int y,
    int fontSize,
    int r,
    int g,
    int b,
    int a,
  ) {
    var ptr = _stringCache[text];
    if (ptr == null) {
      ptr = text.toNativeUtf8();
      _stringCache[text] = ptr;
    }
    _drawText(ptr, x, y, fontSize, r, g, b, a);
  }

  void drawCircle(
    int centerX,
    int centerY,
    double radius,
    int r,
    int g,
    int b,
    int a,
  ) {
    _drawCircle(centerX, centerY, radius, r, g, b, a);
  }

  void drawCircleLines(
    int centerX,
    int centerY,
    double radius,
    int r,
    int g,
    int b,
    int a,
  ) {
    _drawCircleLines(centerX, centerY, radius, r, g, b, a);
  }

  void drawArc(
    int centerX,
    int centerY,
    double radius,
    double startAngle,
    double endAngle,
    int segments,
    int r,
    int g,
    int b,
    int a,
  ) {
    _drawArc(centerX, centerY, radius, startAngle, endAngle, segments, r, g, b, a);
  }

  void drawArcLines(
    int centerX,
    int centerY,
    double radius,
    double startAngle,
    double endAngle,
    int segments,
    int r,
    int g,
    int b,
    int a,
  ) {
    _drawArcLines(
      centerX,
      centerY,
      radius,
      startAngle,
      endAngle,
      segments,
      r,
      g,
      b,
      a,
    );
  }

  int loadTexture(String filePath) {
    final ptr = filePath.toNativeUtf8();
    final id = _loadTexture(ptr);
    calloc.free(ptr);
    return id;
  }

  void drawTexture(
    int textureId,
    int x,
    int y,
    int width,
    int height,
    double rotation,
    int r,
    int g,
    int b,
    int a,
  ) {
    _drawTexture(textureId, x, y, width, height, rotation, r, g, b, a);
  }

  int getTextureWidth(int textureId) => _getTextureWidth(textureId);

  int getTextureHeight(int textureId) => _getTextureHeight(textureId);

  bool unloadTexture(int textureId) => _unloadTexture(textureId) != 0;

  void drawRoundRect(
    int x,
    int y,
    int w,
    int h,
    double roundness,
    int segments,
    int r,
    int g,
    int b,
    int a,
  ) {
    _drawRoundRect(x, y, w, h, roundness, segments, r, g, b, a);
  }

  void drawRoundRectLines(
    int x,
    int y,
    int w,
    int h,
    double roundness,
    int segments,
    double lineThick,
    int r,
    int g,
    int b,
    int a,
  ) {
    _drawRoundRectLines(
      x,
      y,
      w,
      h,
      roundness,
      segments,
      lineThick,
      r,
      g,
      b,
      a,
    );
  }

  void drawPoly(
    int centerX,
    int centerY,
    int sides,
    double radius,
    double rotation,
    int r,
    int g,
    int b,
    int a,
  ) {
    _drawPoly(centerX, centerY, sides, radius, rotation, r, g, b, a);
  }

  void drawPolyLines(
    int centerX,
    int centerY,
    int sides,
    double radius,
    double rotation,
    double lineThick,
    int r,
    int g,
    int b,
    int a,
  ) {
    _drawPolyLines(
      centerX,
      centerY,
      sides,
      radius,
      rotation,
      lineThick,
      r,
      g,
      b,
      a,
    );
  }

  void drawTriangle(
    int x1,
    int y1,
    int x2,
    int y2,
    int x3,
    int y3,
    int r,
    int g,
    int b,
    int a,
  ) {
    _drawTriangle(x1, y1, x2, y2, x3, y3, r, g, b, a);
  }

  void drawTriangleLines(
    int x1,
    int y1,
    int x2,
    int y2,
    int x3,
    int y3,
    int r,
    int g,
    int b,
    int a,
  ) {
    _drawTriangleLines(x1, y1, x2, y2, x3, y3, r, g, b, a);
  }

  void clearStringCache() {
    for (final ptr in _stringCache.values) {
      calloc.free(ptr);
    }
    _stringCache.clear();
  }
}
