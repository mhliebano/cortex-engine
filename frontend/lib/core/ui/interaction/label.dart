import 'package:cortex/core/context2d.dart';
import 'package:cortex/core/context3d.dart';
import 'package:cortex/core/ui/element.dart';
import 'package:cortex/core/ui/style.dart';

class Label extends Element {
  String text;
  late int fontSize;
  late ColorRGBA color;

  Label({
    String? className,
    required this.text,
    super.expand,
    super.fillWidth,
    super.fillHeight,
    super.marginRight,
    super.marginBottom,
  }) {
    final style = className != null ? Style.merge(className) : null;
    fontSize = style?.fontSize ?? 14;
    color = style?.textColor ?? ColorRGBA.white;

    width = text.length * (fontSize ~/ 2);
    height = fontSize + 6;
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    ctx2d.drawText(text, x, y, fontSize, color);
  }
}
