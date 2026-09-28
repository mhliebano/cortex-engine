/// Geometría de márgenes y recortes internos de bordes.
class EdgeInsets {
  final double top;
  final double right;
  final double bottom;
  final double left;

  const EdgeInsets.all(double value)
      : top = value,
        right = value,
        bottom = value,
        left = value;

  const EdgeInsets.symmetric({
    double vertical = 0.0,
    double horizontal = 0.0,
  })  : top = vertical,
        bottom = vertical,
        left = horizontal,
        right = horizontal;

  const EdgeInsets.only({
    this.top = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
    this.left = 0.0,
  });

  List<double> get asArray => [top, right, bottom, left];
}
