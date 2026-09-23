/// Alineación a lo largo del eje principal (Horizontal en Row, Vertical en Column).
enum MainAxisAlignment {
  /// Ubica los hijos al inicio del eje principal.
  start,

  /// Ubica los hijos al final del eje principal.
  end,

  /// Centra los hijos en el eje principal.
  center,

  /// Distribuye los hijos de borde a borde dejando espacio igual entre ellos.
  spaceBetween,

  /// Distribuye los hijos dejando espacio uniforme a los lados de cada hijo.
  spaceAround,

  /// Distribuye los hijos dejando exactamente el mismo espacio entre todos los elementos y los bordes.
  spaceEvenly,
}

/// Alineación a lo largo del eje cruzado (Vertical en Row, Horizontal en Column).
enum CrossAxisAlignment {
  /// Alinea los hijos al inicio del eje cruzado (arriba en Row, izquierda en Column).
  start,

  /// Centra los hijos en el eje cruzado (centro vertical en Row, centro horizontal en Column).
  center,

  /// Alinea los hijos al final del eje cruzado (abajo en Row, derecha en Column).
  end,

  /// Estira los hijos para llenar todo el espacio disponible en el eje cruzado.
  stretch,
}

/// Modos de dimensionamiento del eje principal.
enum MainAxisSize {
  /// Ocupa todo el espacio disponible en el eje principal.
  max,

  /// Se ajusta al tamaño exacto de sus hijos en el eje principal.
  min,
}
