import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/controls/icon_button.dart';
import 'package:frontend/core/ui/cortex_node.dart';
import 'package:frontend/core/ui/icons.dart';

/// Componente de Carrusel Paginado y Animado (`Carousel`) bajo la arquitectura `ControlNode`.
///
/// Ofrece una experiencia visual fluida e interactiva:
/// - Transición animada suave entre diapositivas (*Slide interpolation*).
/// - Botones flotantes de navegación rápida prev/next.
/// - Píldora indicadora animada de página activa (`• ━━ •`).
/// - Soporte para reproducción automática pasiva (`autoPlay`).
class Carousel extends ControlNode {
  final List<CortexNode> children;
  int currentIndex;
  final bool showIndicators;
  final bool showControls;
  final bool autoPlay;
  final double autoPlayIntervalSec;
  final void Function(int index)? onPageChanged;

  late final IconButton _prevBtn;
  late final IconButton _nextBtn;

  double _animOffset = 0.0;
  int _targetIndex = 0;
  double _autoPlayTimer = 0.0;
  bool _isHovered = false;

  Carousel({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    required this.children,
    this.currentIndex = 0,
    this.showIndicators = true,
    this.showControls = true,
    this.autoPlay = false,
    this.autoPlayIntervalSec = 4.0,
    this.onPageChanged,
  }) {
    _targetIndex = currentIndex;
    _animOffset = currentIndex.toDouble();

    _prevBtn = IconButton(
      icon: Icons.chevronLeft,
      onClick: previousPage,
    );

    _nextBtn = IconButton(
      icon: Icons.chevronRight,
      onClick: nextPage,
    );

    _updateDimensions();
  }

  void _updateDimensions() {
    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    } else if (width <= 0) {
      width = 500;
    }

    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else if (height <= 0) {
      height = 240;
    }
    _updateLayout();
  }

  @override
  bool get isFlexWidth => true;

  @override
  bool get isFlexHeight => true;

  @override
  List<CortexNode> get childrenElements => [
        ...children,
        _prevBtn,
        _nextBtn,
      ];

  void previousPage() {
    if (children.isEmpty) return;
    _targetIndex = (currentIndex - 1 + children.length) % children.length;
    currentIndex = _targetIndex;
    _autoPlayTimer = 0.0;
    onPageChanged?.call(currentIndex);
  }

  void nextPage() {
    if (children.isEmpty) return;
    _targetIndex = (currentIndex + 1) % children.length;
    currentIndex = _targetIndex;
    _autoPlayTimer = 0.0;
    onPageChanged?.call(currentIndex);
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
  void onResize(int maxWidth, int maxHeight) {
    final layout = currentLayout;

    final wRule = layout.width;
    if (wRule != null) {
      if (wRule == double.infinity) {
        width = maxWidth;
      } else if (wRule > 0.0 && wRule <= 1.0) {
        width = (maxWidth * wRule).round();
      } else if (wRule.isFinite) {
        width = wRule.round();
      } else {
        width = maxWidth;
      }
    } else {
      width = maxWidth;
    }

    final hRule = layout.height;
    if (hRule != null) {
      if (hRule == double.infinity) {
        height = maxHeight;
      } else if (hRule > 0.0 && hRule <= 1.0) {
        height = (maxHeight * hRule).round();
      } else if (hRule.isFinite) {
        height = hRule.round();
      } else {
        height = maxHeight;
      }
    } else {
      height = (maxHeight > 0 && maxHeight != ControlNode.unconstrained)
          ? maxHeight
          : 240;
    }

    _updateLayout();
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);
    if (!isVisible || !isEnabled || children.isEmpty) return;

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

    final style = currentStyle;
    final bgCol = style.bgColor ?? const ColorRGBA(26, 32, 44, 255);
    final borderCol = _isHovered
        ? (style.accentColor ?? const ColorRGBA(41, 128, 185, 255))
        : (style.borderColor ?? const ColorRGBA(55, 65, 82, 255));

    ctx2d.drawRoundRect(x, y, width, height, 0.1, color: bgCol);
    ctx2d.drawRoundRectLines(x, y, width, height, 0.1, lineThick: 1.0, color: borderCol);

    // 2. Renderizar diapositivas dentro del área Scissor recortada
    final slideW = width - 110;
    final slideH = height - 50;
    final clipX = x + 55;
    final clipY = y + 10;

    ctx2d.beginScissor(clipX, clipY, slideW, slideH);

    for (int i = 0; i < children.length; i++) {
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
            ? (style.accentColor ?? const ColorRGBA(41, 128, 185, 255))
            : const ColorRGBA(80, 92, 112, 255);

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
}

