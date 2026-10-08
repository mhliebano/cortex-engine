import 'package:frontend/core/context2d.dart';

/// Maneja estrictamente la pintura y propiedades cosméticas de los componentes.
class StyleRules {
  final ColorRGBA? bgColor;
  final ColorRGBA? hoverColor;
  final ColorRGBA? textColor;
  final ColorRGBA? borderColor;
  final ColorRGBA? accentColor;
  final ColorRGBA? activeColor;
  final ColorRGBA? dividerColor;
  final double? borderRadius;
  final int? fontSize;

  const StyleRules({
    this.bgColor,
    this.hoverColor,
    this.textColor,
    this.borderColor,
    this.accentColor,
    this.activeColor,
    this.dividerColor,
    this.borderRadius,
    this.fontSize,
  });

  static final Map<String, StyleRules> _registry = {};

  /// Registra una regla de estilo en el registro global.
  static void register(String className, StyleRules style) {
    _registry[className] = style;
  }

  /// Obtiene una regla de estilo por su identificador.
  static StyleRules? get(String className) {
    return _registry[className];
  }

  /// Combina múltiples clases de estilo separadas por espacios.
  static StyleRules merge(String classNames) {
    ColorRGBA? bg;
    ColorRGBA? hover;
    ColorRGBA? text;
    ColorRGBA? border;
    ColorRGBA? accent;
    ColorRGBA? active;
    ColorRGBA? divider;
    double? radius;
    int? font;

    final names = classNames.split(' ');
    for (final rawName in names) {
      final name = rawName.trim();
      if (name.isEmpty) continue;
      final s = _registry[name];
      if (s != null) {
        if (s.bgColor != null) bg = s.bgColor;
        if (s.hoverColor != null) hover = s.hoverColor;
        if (s.textColor != null) text = s.textColor;
        if (s.borderColor != null) border = s.borderColor;
        if (s.accentColor != null) accent = s.accentColor;
        if (s.activeColor != null) active = s.activeColor;
        if (s.dividerColor != null) divider = s.dividerColor;
        if (s.borderRadius != null) radius = s.borderRadius;
        if (s.fontSize != null) font = s.fontSize;
      }
    }

    return StyleRules(
      bgColor: bg,
      hoverColor: hover,
      textColor: text,
      borderColor: border,
      accentColor: accent,
      activeColor: active,
      dividerColor: divider,
      borderRadius: radius,
      fontSize: font,
    );
  }
}
