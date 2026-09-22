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

  // --- Text Arena por frame ---
  // Buffer nativo reutilizable que vive durante un frame completo.
  // Se resetea (offset → 0) tras EndDrawing; Raylib copia el texto síncronamente
  // por lo que los punteros son seguros durante toda la fase de render.
  static const int _arenaInitialSize = 64 * 1024; // 64 KB
  Pointer<Uint8> _arenaBuffer = calloc<Uint8>(_arenaInitialSize);
  int _arenaCapacity = _arenaInitialSize;
  int _arenaOffset = 0;

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
    final ptr = _arenaWriteUtf8(text);
    _drawText(ptr, x, y, fontSize, r, g, b, a);
  }

  /// Copia [text] codificado en UTF-8 + '\0' en el arena y devuelve el puntero.
  /// Si el texto no cabe, crece el buffer (realloc ×2) antes de escribir.
  Pointer<Utf8> _arenaWriteUtf8(String text) {
    // Codifica el texto a bytes UTF-8 usando el encoder propio (sin malloc intermedio)
    final bytes = _encodeUtf8(text); // bytes sin '\0'
    final needed = bytes.length + 1; // +1 para el terminador nulo

    // Crecer si no cabe
    if (_arenaOffset + needed > _arenaCapacity) {
      int newCapacity = _arenaCapacity;
      while (newCapacity < _arenaOffset + needed) {
        newCapacity *= 2;
      }
      final newBuffer = calloc<Uint8>(newCapacity);
      // Copiar contenido anterior (para robustez, aunque no se reutiliza entre frames)
      for (int i = 0; i < _arenaOffset; i++) {
        newBuffer[i] = _arenaBuffer[i];
      }
      calloc.free(_arenaBuffer);
      _arenaBuffer = newBuffer;
      _arenaCapacity = newCapacity;
    }

    final start = _arenaOffset;
    for (int i = 0; i < bytes.length; i++) {
      _arenaBuffer[_arenaOffset++] = bytes[i];
    }
    _arenaBuffer[_arenaOffset++] = 0; // terminador nulo

    return (_arenaBuffer + start).cast<Utf8>();
  }

  /// Codifica [text] a bytes UTF-8 sin terminador nulo.
  static List<int> _encodeUtf8(String text) {
    final result = <int>[];
    for (final rune in text.runes) {
      if (rune < 0x80) {
        result.add(rune);
      } else if (rune < 0x800) {
        result.add(0xC0 | (rune >> 6));
        result.add(0x80 | (rune & 0x3F));
      } else if (rune < 0x10000) {
        result.add(0xE0 | (rune >> 12));
        result.add(0x80 | ((rune >> 6) & 0x3F));
        result.add(0x80 | (rune & 0x3F));
      } else {
        result.add(0xF0 | (rune >> 18));
        result.add(0x80 | ((rune >> 12) & 0x3F));
        result.add(0x80 | ((rune >> 6) & 0x3F));
        result.add(0x80 | (rune & 0x3F));
      }
    }
    return result;
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

  /// Resetea el arena al inicio de cada frame (tras EndDrawing).
  /// Pone el offset a 0 — los punteros del frame anterior se invalidan,
  /// pero Raylib ya los copió síncronamente durante el render.
  void resetTextArena() {
    _arenaOffset = 0;
  }
}
