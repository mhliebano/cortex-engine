import 'package:cortex/engine/context2d.dart';
import 'package:cortex/engine/context3d.dart';
import 'package:cortex/engine/input.dart';
import 'package:cortex/engine/ui/element.dart';
import 'package:cortex/engine/ui/icons.dart';
import 'package:cortex/engine/ui/interaction/icon_button.dart';

import 'package:cortex/engine/ui/style.dart';

/// Componente de Carrusel Paginado y Animado (`Carousel`).
///
/// Ofrece una experiencia visual fluida e interactiva:
/// - Transición animada suave entre diapositivas (*Slide interpolation*).
/// - Botones flotantes de navegación rápida prev/next.
/// - Píldora indicadora animada de página activa (`• ━━ •`).
/// - Soporte para reproducción automática pasiva (`autoPlay`).
class Carousel extends Element {
  final List<Element> children;
  int currentIndex;
  final bool showIndicators;
  final bool showControls;
  final bool autoPlay;
  final double autoPlayIntervalSec;
  final void Function(int index)? onPageChanged;

  late IconButton _prevBtn;
  late IconButton _nextBtn;

  double _animOffset = 0.0;
  int _targetIndex = 0;
  double _autoPlayTimer = 0.0;
  bool _isHovered = false;

  Carousel({
    String? className,
    required this.children,
    this.currentIndex = 0,
    this.showIndicators = true,
    this.showControls = true,
    this.autoPlay = false,
    this.autoPlayIntervalSec = 4.0,
    this.onPageChanged,
    int width = 0,
    int height = 0,
    super.expand,
    super.fillWidth,
    super.fillHeight,
    super.marginRight,
    super.marginBottom,
  }) {
    final style = className != null ? Style.merge(className) : null;
    this.width = width != 0 ? width : (style?.width ?? 500);
    this.height = height != 0 ? height : (style?.height ?? 240);
    _targetIndex = currentIndex;
    _animOffset = currentIndex.toDouble();

    _prevBtn = IconButton(
      icon: Icons.chevronLeft,
      variant: IconButtonVariant.filled,
      onPressed: previousPage,
    );

    _nextBtn = IconButton(
      icon: Icons.chevronRight,
      variant: IconButtonVariant.filled,
      onPressed: nextPage,
    );

    _updateLayout();
  }

  void previousPage() {
    if (children.isEmpty) return;
    _targetIndex = (currentIndex - 1 + children.length) % children.length;
    currentIndex = _targetIndex;
    _autoPlayTimer = 0.0;
    if (onPageChanged != null) onPageChanged!(currentIndex);
  }

  void nextPage() {
    if (children.isEmpty) return;
    _targetIndex = (currentIndex + 1) % children.length;
    currentIndex = _targetIndex;
    _autoPlayTimer = 0.0;
    if (onPageChanged != null) onPageChanged!(currentIndex);
  }

  void _updateLayout() {
    if (children.isEmpty) return;

    final btnY = y + (height ~/ 2) - 18;
    _prevBtn.x = x + 12;
    _prevBtn.y = btnY;

    _nextBtn.x = x + width - 48;
    _nextBtn.y = btnY;

    final childW = width > 120 ? width - 120 : 0;
    final childH = height > 55 ? height - 55 : 0;

    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      child.onResize(childW, childH);
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible || children.isEmpty) return;

    _isHovered = input.isHovering(x, y, width, height);

    // 1. Interpolación suave de transición entre diapositivas
    final diff = _targetIndex.toDouble() - _animOffset;
    if (diff.abs() > 0.001) {
      _animOffset += diff * (dt * 12.0).clamp(0.0, 1.0);
    } else {
      _animOffset = _targetIndex.toDouble();
    }

    // 2. Reproducción automática de diapositivas
    if (autoPlay && !_isHovered && children.length > 1) {
      _autoPlayTimer += dt;
      if (_autoPlayTimer >= autoPlayIntervalSec) {
        nextPage();
      }
    }

    _updateLayout();

    if (showControls && children.length > 1) {
      _prevBtn.onUpdate(dt, input);
      _nextBtn.onUpdate(dt, input);
    }

    final activeChild = children[currentIndex];
    activeChild.onUpdate(dt, input);
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible || children.isEmpty) return;

    _updateLayout();

    // 1. Fondo de contenedor carrusel
    final bgCol = const ColorRGBA(26, 32, 44);
    final borderCol = _isHovered
        ? const ColorRGBA(41, 128, 185)
        : const ColorRGBA(55, 65, 82);

    ctx2d.drawRoundRect(x, y, width, height, 0.1, color: bgCol);
    ctx2d.drawRoundRectLines(x, y, width, height, 0.1, color: borderCol);

    // 2. Renderizar diapositivas dentro del área Scissor recortada
    final slideW = width - 110;
    final slideH = height - 50;
    final clipX = x + 55;
    final clipY = y + 10;

    ctx2d.beginScissor(clipX, clipY, slideW, slideH);

    for (int i = 0; i < children.length; i++) {
      // Calcular posición desplazada X de cada diapositiva según la animación
      final offsetMultiplier = i.toDouble() - _animOffset;
      if (offsetMultiplier.abs() < 1.5) {
        final child = children[i];
        child.x = (clipX + (offsetMultiplier * (slideW + 20))).toInt();
        child.y = clipY;
        child.onRender(ctx2d, ctx3d);
      }
    }

    ctx2d.endScissor();

    // 3. Botones flotantes de navegación
    if (showControls && children.length > 1) {
      _prevBtn.onRender(ctx2d, ctx3d);
      _nextBtn.onRender(ctx2d, ctx3d);
    }

    // 4. Barra de indicadores de página estilo píldora activa
    if (showIndicators && children.length > 1) {
      final dotsY = y + height - 18;
      final totalWidth = (children.length * 10) + 14;
      int dotX = x + (width ~/ 2) - (totalWidth ~/ 2);

      for (int i = 0; i < children.length; i++) {
        final isActive = i == currentIndex;
        final dotColor = isActive
            ? const ColorRGBA(41, 128, 185)
            : const ColorRGBA(80, 92, 112);

        if (isActive) {
          ctx2d.drawRoundRect(dotX, dotsY, 22, 6, 0.5, color: dotColor);
          dotX += 26;
        } else {
          ctx2d.drawCircle(dotX + 3, dotsY + 3, 3.0, dotColor);
          dotX += 14;
        }
      }
    }
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible || children.isEmpty) return;
    if (showControls && children.length > 1) {
      _prevBtn.onRenderOverlay(ctx2d, ctx3d);
      _nextBtn.onRenderOverlay(ctx2d, ctx3d);
    }
    final activeChild = children[currentIndex];
    activeChild.onRenderOverlay(ctx2d, ctx3d);
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    super.onResize(allocatedWidth, allocatedHeight);
    _updateLayout();
  }
}
