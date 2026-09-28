import 'package:frontend/wrappers/graphics2d.dart';
import 'package:frontend/wrappers/renderer.dart';
import 'package:frontend/core/input.dart';

class ColorRGBA {
  final int r, g, b, a;
  const ColorRGBA(this.r, this.g, this.b, [this.a = 255]);

  static const ColorRGBA darkGray = ColorRGBA(40, 44, 52);
  static const ColorRGBA lightGray = ColorRGBA(60, 64, 72);
  static const ColorRGBA accentBlue = ColorRGBA(41, 128, 185);
  static const ColorRGBA hoverBlue = ColorRGBA(52, 152, 219);
  static const ColorRGBA white = ColorRGBA(245, 245, 245);
  static const ColorRGBA black = ColorRGBA(15, 15, 15);
  static const ColorRGBA transparent = ColorRGBA(0, 0, 0, 0);
}

class _ScissorRect {
  final int x, y, width, height;
  const _ScissorRect(this.x, this.y, this.width, this.height);
}

class Context2D {
  final Graphics2D _g2d = Graphics2D();
  final Renderer _renderer = Renderer();
  final InputEngine _input = InputEngine();
  final List<_ScissorRect> _scissorStack = [];

  double _scaleX = 1.0;
  double _scaleY = 1.0;
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  bool _hasTransform = false;

  void translate(double dx, double dy) {
    _offsetX = dx;
    _offsetY = dy;
    _hasTransform = true;
  }

  void scale(double sx, [double? sy]) {
    _scaleX = sx;
    _scaleY = sy ?? sx;
    _hasTransform = true;
  }

  void setTransform({
    required double scale,
    required double offsetX,
    required double offsetY,
  }) {
    _scaleX = scale;
    _scaleY = scale;
    _offsetX = offsetX;
    _offsetY = offsetY;
    _hasTransform = true;
  }

  void resetTransform() {
    _scaleX = 1.0;
    _scaleY = 1.0;
    _offsetX = 0.0;
    _offsetY = 0.0;
    _hasTransform = false;
  }

  int _tx(int x) => _hasTransform ? (x * _scaleX + _offsetX).round() : x;
  int _ty(int y) => _hasTransform ? (y * _scaleY + _offsetY).round() : y;
  int _tw(int w) => _hasTransform ? (w * _scaleX).round() : w;
  int _th(int h) => _hasTransform ? (h * _scaleY).round() : h;
  int _tsz(int sz) => _hasTransform ? (sz * _scaleY).round() : sz;
  double _tr(double r) => _hasTransform ? r * _scaleX : r;

  bool loadFont(String filePath, [int fontSize = 32]) {
    return _g2d.loadFont(filePath, fontSize);
  }

  bool loadIconFont(String filePath, [int fontSize = 32]) {
    return _g2d.loadIconFont(filePath, fontSize);
  }

  void drawPanel(
    int x,
    int y,
    int w,
    int h, {
    ColorRGBA bgColor = ColorRGBA.darkGray,
    ColorRGBA borderColor = ColorRGBA.lightGray,
  }) {
    final px = _tx(x);
    final py = _ty(y);
    final pw = _tw(w);
    final ph = _th(h);

    _g2d.drawRect(px, py, pw, ph, bgColor.r, bgColor.g, bgColor.b, bgColor.a);
    if (borderColor.a > 0 && pw > 1 && ph > 1) {
      _g2d.drawRectLines(
        px,
        py,
        pw - 1,
        ph - 1,
        borderColor.r,
        borderColor.g,
        borderColor.b,
        borderColor.a,
      );
    }
  }

  void beginScissor(int x, int y, int width, int height) {
    final px = _tx(x);
    final py = _ty(y);
    final pw = _tw(width);
    final ph = _th(height);

    if (_scissorStack.isNotEmpty) {
      final parent = _scissorStack.last;
      final parentRight = parent.x + parent.width;
      final parentBottom = parent.y + parent.height;
      final childRight = px + pw;
      final childBottom = py + ph;

      final ix = px > parent.x ? px : parent.x;
      final iy = py > parent.y ? py : parent.y;
      final iright = childRight < parentRight ? childRight : parentRight;
      final ibottom = childBottom < parentBottom ? childBottom : parentBottom;

      final iw = iright > ix ? iright - ix : 0;
      final ih = ibottom > iy ? ibottom - iy : 0;

      final intersected = _ScissorRect(ix, iy, iw, ih);
      _scissorStack.add(intersected);
      _renderer.beginScissor(ix, iy, iw, ih);
    } else {
      final rect = _ScissorRect(px, py, pw, ph);
      _scissorStack.add(rect);
      _renderer.beginScissor(px, py, pw, ph);
    }
  }

  void endScissor() {
    if (_scissorStack.isNotEmpty) {
      _scissorStack.removeLast();
    }
    if (_scissorStack.isNotEmpty) {
      final parent = _scissorStack.last;
      _renderer.beginScissor(parent.x, parent.y, parent.width, parent.height);
    } else {
      _renderer.endScissor();
    }
  }

  void drawText(
    String text,
    int x,
    int y,
    int fontSize, [
    ColorRGBA color = ColorRGBA.white,
  ]) {
    _g2d.drawText(text, _tx(x), _ty(y), _tsz(fontSize), color.r, color.g, color.b, color.a);
  }

  /// Resetea el arena de texto al final de cada frame (llámalo tras endFrame()).
  /// Libera efectivamente todos los punteros UTF-8 del frame anterior poniendo
  /// el offset a 0, sin ejecutar ningún free() nativo.
  void resetTextArena() {
    _g2d.resetTextArena();
  }

  void drawRect(int x, int y, int w, int h, ColorRGBA color) {
    _g2d.drawRect(_tx(x), _ty(y), _tw(w), _th(h), color.r, color.g, color.b, color.a);
  }

  bool drawButton(
    int x,
    int y,
    int w,
    int h,
    String label, {
    ColorRGBA defaultColor = ColorRGBA.accentBlue,
    ColorRGBA hoverColor = ColorRGBA.hoverBlue,
    ColorRGBA textColor = ColorRGBA.white,
    int fontSize = 16,
  }) {
    final isHover = _input.isHovering(x, y, w, h);
    final bg = isHover ? hoverColor : defaultColor;

    final px = _tx(x);
    final py = _ty(y);
    final pw = _tw(w);
    final ph = _th(h);

    _g2d.drawRect(px, py, pw, ph, bg.r, bg.g, bg.b, bg.a);
    _g2d.drawRectLines(px, py, pw, ph, 255, 255, 255, 100);

    final textX = _tx(x + 15);
    final textY = _ty(y + (h ~/ 4));
    _g2d.drawText(
      label,
      textX,
      textY,
      _tsz(fontSize),
      textColor.r,
      textColor.g,
      textColor.b,
      textColor.a,
    );

    return isHover && _input.isMouseButtonPressed(MouseButtons.left);
  }

  void drawCircle(int centerX, int centerY, double radius, ColorRGBA color) {
    _g2d.drawCircle(
      _tx(centerX),
      _ty(centerY),
      _tr(radius),
      color.r,
      color.g,
      color.b,
      color.a,
    );
  }

  void drawCircleLines(
    int centerX,
    int centerY,
    double radius,
    ColorRGBA color,
  ) {
    _g2d.drawCircleLines(
      _tx(centerX),
      _ty(centerY),
      _tr(radius),
      color.r,
      color.g,
      color.b,
      color.a,
    );
  }

  void drawArc(
    int centerX,
    int centerY,
    double radius,
    double startAngle,
    double endAngle, {
    int segments = 36,
    ColorRGBA color = ColorRGBA.white,
  }) {
    _g2d.drawArc(
      _tx(centerX),
      _ty(centerY),
      _tr(radius),
      startAngle,
      endAngle,
      segments,
      color.r,
      color.g,
      color.b,
      color.a,
    );
  }

  void drawArcLines(
    int centerX,
    int centerY,
    double radius,
    double startAngle,
    double endAngle, {
    int segments = 36,
    ColorRGBA color = ColorRGBA.white,
  }) {
    _g2d.drawArcLines(
      _tx(centerX),
      _ty(centerY),
      _tr(radius),
      startAngle,
      endAngle,
      segments,
      color.r,
      color.g,
      color.b,
      color.a,
    );
  }

  int loadImage(String filePath) {
    return _g2d.loadTexture(filePath);
  }

  void drawImage(
    int textureId,
    int x,
    int y, {
    int width = 0,
    int height = 0,
    double rotation = 0.0,
    ColorRGBA tint = ColorRGBA.white,
  }) {
    _g2d.drawTexture(
      textureId,
      _tx(x),
      _ty(y),
      _tw(width),
      _th(height),
      rotation,
      tint.r,
      tint.g,
      tint.b,
      tint.a,
    );
  }

  int getImageWidth(int textureId) => _g2d.getTextureWidth(textureId);
  int getImageHeight(int textureId) => _g2d.getTextureHeight(textureId);
  bool unloadImage(int textureId) => _g2d.unloadTexture(textureId);

  void drawRoundRect(
    int x,
    int y,
    int w,
    int h,
    double roundness, {
    int segments = 16,
    ColorRGBA color = ColorRGBA.white,
  }) {
    _g2d.drawRoundRect(
      _tx(x),
      _ty(y),
      _tw(w),
      _th(h),
      roundness,
      segments,
      color.r,
      color.g,
      color.b,
      color.a,
    );
  }

  void drawRoundRectLines(
    int x,
    int y,
    int w,
    int h,
    double roundness, {
    int segments = 16,
    double lineThick = 1.0,
    ColorRGBA color = ColorRGBA.white,
  }) {
    _g2d.drawRoundRectLines(
      _tx(x),
      _ty(y),
      _tw(w),
      _th(h),
      roundness,
      segments,
      lineThick * _scaleX,
      color.r,
      color.g,
      color.b,
      color.a,
    );
  }

  void drawPoly(
    int centerX,
    int centerY,
    int sides,
    double radius, {
    double rotation = 0.0,
    ColorRGBA color = ColorRGBA.white,
  }) {
    _g2d.drawPoly(
      _tx(centerX),
      _ty(centerY),
      sides,
      _tr(radius),
      rotation,
      color.r,
      color.g,
      color.b,
      color.a,
    );
  }

  void drawPolyLines(
    int centerX,
    int centerY,
    int sides,
    double radius, {
    double rotation = 0.0,
    double lineThick = 1.0,
    ColorRGBA color = ColorRGBA.white,
  }) {
    _g2d.drawPolyLines(
      _tx(centerX),
      _ty(centerY),
      sides,
      _tr(radius),
      rotation,
      lineThick * _scaleX,
      color.r,
      color.g,
      color.b,
      color.a,
    );
  }

  void drawTriangle(
    int x1,
    int y1,
    int x2,
    int y2,
    int x3,
    int y3,
    ColorRGBA color,
  ) {
    _g2d.drawTriangle(
      _tx(x1),
      _ty(y1),
      _tx(x2),
      _ty(y2),
      _tx(x3),
      _ty(y3),
      color.r,
      color.g,
      color.b,
      color.a,
    );
  }

  void drawTriangleLines(
    int x1,
    int y1,
    int x2,
    int y2,
    int x3,
    int y3,
    ColorRGBA color,
  ) {
    _g2d.drawTriangleLines(
      _tx(x1),
      _ty(y1),
      _tx(x2),
      _ty(y2),
      _tx(x3),
      _ty(y3),
      color.r,
      color.g,
      color.b,
      color.a,
    );
  }
}
