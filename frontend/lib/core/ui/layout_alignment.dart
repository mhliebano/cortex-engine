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
