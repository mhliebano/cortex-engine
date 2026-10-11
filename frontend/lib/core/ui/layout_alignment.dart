/// Alineación del eje principal (Horizontal en Row, Vertical en Col).
enum MainAlign {
  start,
  center,
  end,
  spaceBetween,
  spaceAround,
}

/// Alineación del eje cruzado (Vertical en Row, Horizontal en Col).
enum CrossAlign {
  start,
  center,
  end,
  stretch,
}

/// Comportamiento de desbordamiento de contenido.
enum Overflow {
  visible,
  hidden,
  scroll,
  auto,
}

/// Alineación a lo largo del eje principal (Compatibilidad).
enum MainAxisAlignment {
  start,
  end,
  center,
  spaceBetween,
  spaceAround,
  spaceEvenly,
}

/// Alineación a lo largo del eje cruzado (Compatibilidad).
enum CrossAxisAlignment {
  start,
  center,
  end,
  stretch,
}

/// Modos de dimensionamiento del eje principal.
enum MainAxisSize {
  max,
  min,
}

/// Alineación bidimensional en una caja o contenedor (9 posiciones).
enum Alignment2D {
  topLeft(0.0, 0.0),
  topCenter(0.5, 0.0),
  topRight(1.0, 0.0),
  centerLeft(0.0, 0.5),
  center(0.5, 0.5),
  centerRight(1.0, 0.5),
  bottomLeft(0.0, 1.0),
  bottomCenter(0.5, 1.0),
  bottomRight(1.0, 1.0);

  final double fx;
  final double fy;

  const Alignment2D(this.fx, this.fy);
}

typedef Alignment = Alignment2D;
