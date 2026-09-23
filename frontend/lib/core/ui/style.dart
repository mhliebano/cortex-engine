import 'package:cortex/core/context2d.dart';

/// Sistema de Estilos tipo CSS para componentes UI.
/// Permite definir clases CSS globales (ej. `.fancy-button`, `.sidebar-panel`)
/// y aplicarlas usando `className: "fancy-button"`.
class Style {
  final ColorRGBA? bgColor;
  final ColorRGBA? hoverColor;
  final ColorRGBA? textColor;
  final ColorRGBA? borderColor;
  final ColorRGBA? accentColor;
  final ColorRGBA? activeColor;
  final ColorRGBA? dividerColor;
  final int? fontSize;
  final int? padding;
  final int? spacing;
  final int? width;
  final int? height;
  final double? borderRadius;

  const Style({
    this.bgColor,
    this.hoverColor,
    this.textColor,
    this.borderColor,
    this.accentColor,
    this.activeColor,
    this.dividerColor,
    this.fontSize,
    this.padding,
    this.spacing,
    this.width,
    this.height,
    this.borderRadius,
  });

  static final Map<String, Style> _registry = {};

  /// Registra una clase CSS nombrada en el registro global de estilos.
  static void register(String className, Style style) {
    _registry[className] = style;
  }

  /// Obtiene un estilo por su nombre de clase CSS.
  static Style? get(String className) {
    return _registry[className];
  }

  /// Combina múltiples clases CSS separadas por espacio (ej. "btn btn-primary").
  static Style merge(String classNames) {
    ColorRGBA? bg;
    ColorRGBA? hover;
    ColorRGBA? text;
    ColorRGBA? border;
    ColorRGBA? accent;
    ColorRGBA? active;
    ColorRGBA? divider;
    int? font;
    int? pad;
    int? space;
    int? w;
    int? h;
    double? radius;

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
        if (s.fontSize != null) font = s.fontSize;
        if (s.padding != null) pad = s.padding;
        if (s.spacing != null) space = s.spacing;
        if (s.width != null) w = s.width;
        if (s.height != null) h = s.height;
        if (s.borderRadius != null) radius = s.borderRadius;
      }
    }

    return Style(
      bgColor: bg,
      hoverColor: hover,
      textColor: text,
      borderColor: border,
      accentColor: accent,
      activeColor: active,
      dividerColor: divider,
      fontSize: font,
      padding: pad,
      spacing: space,
      width: w,
      height: h,
      borderRadius: radius,
    );
  }
}
