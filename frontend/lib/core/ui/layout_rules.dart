import 'package:frontend/core/ui/edge_insets.dart';

/// Maneja estrictamente la matemática espacial, dimensiones y comportamiento de layout.
class LayoutRules {
  final double? width;
  final double? height;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final int? spacing;

  const LayoutRules({
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.padding,
    this.margin,
    this.spacing,
  });

  static final Map<String, LayoutRules> _registry = {};

  /// Registra una regla de layout en el registro global.
  static void register(String className, LayoutRules layout) {
    _registry[className] = layout;
  }

  /// Obtiene una regla de layout por su identificador.
  static LayoutRules? get(String className) {
    return _registry[className];
  }

  /// Combina múltiples clases de layout separadas por espacios.
  static LayoutRules merge(String classNames) {
    double? w;
    double? h;
    double? minW;
    double? minH;
    double? maxW;
    double? maxH;
    EdgeInsets? pad;
    EdgeInsets? marg;
    int? space;

    final names = classNames.split(' ');
    for (final rawName in names) {
      final name = rawName.trim();
      if (name.isEmpty) continue;
      final l = _registry[name];
      if (l != null) {
        if (l.width != null) w = l.width;
        if (l.height != null) h = l.height;
        if (l.minWidth != null) minW = l.minWidth;
        if (l.minHeight != null) minH = l.minHeight;
        if (l.maxWidth != null) maxW = l.maxWidth;
        if (l.maxHeight != null) maxH = l.maxHeight;
        if (l.padding != null) pad = l.padding;
        if (l.margin != null) marg = l.margin;
        if (l.spacing != null) space = l.spacing;
      }
    }

    return LayoutRules(
      width: w,
      height: h,
      minWidth: minW,
      minHeight: minH,
      maxWidth: maxW,
      maxHeight: maxH,
      padding: pad,
      margin: marg,
      spacing: space,
    );
  }
}
