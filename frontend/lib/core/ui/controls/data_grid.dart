import 'dart:math' as math;
import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/icons.dart';
import 'package:frontend/core/ui/layout_alignment.dart';

/// Definición de una columna dentro de un `DataGrid`.
class DataGridColumn<T> {
  final String id;
  final String title;
  double width;
  final double minWidth;
  final Alignment2D alignment;
  final bool sortable;
  final String Function(T row)? cellValue;
  final ColorRGBA? Function(T row)? cellTextColor;
  final int Function(T a, T b)? comparator;

  DataGridColumn({
    required this.id,
    required this.title,
    this.width = 120.0,
    this.minWidth = 50.0,
    this.alignment = Alignment2D.centerLeft,
    this.sortable = true,
    this.cellValue,
    this.cellTextColor,
    this.comparator,
  });
}

/// Tabla de Datos (`DataGrid`) bajo la arquitectura `ControlNode`.
///
/// Componente de alto rendimiento para listas de corte, despiece de muebles (BOM) e inventario CAD:
/// - Cabecera ordenable interactiva por columnas (clic para alternar ascendente / descendente).
/// - Redimensionamiento interactivo de columnas arrastrando los bordes en la cabecera.
/// - Filas con coloreado alternado cebra (*zebra striping*) y detección de hover.
/// - Selección de filas con soporte para selección simple y doble clic.
/// - Desplazamiento bidireccional suave (vertical y horizontal) con rueda de ratón y barras de desplazamiento.
/// - Recorte de tijera estricto por celda para evitar desbordes de texto.
class DataGrid<T> extends ControlNode {
  final List<DataGridColumn<T>> columns;
  final List<T> rows;
  final int rowHeight;
  final int headerHeight;
  final bool zebraStriping;
  final bool showGridLines;
  final bool resizableColumns;

  final void Function(T row, int index)? onRowSelected;
  final void Function(T row, int index)? onRowDoubleClicked;
  final void Function(String columnId, bool ascending)? onSortChanged;

  String? sortColumnId;
  bool sortAscending = true;
  int? selectedIndex;

  int _hoveredRowIndex = -1;
  int _hoveredHeaderIndex = -1;
  int _hoveredResizeBorderIndex = -1;

  bool _isDraggingBorder = false;
  int _draggedBorderIndex = -1;
  int _dragStartMouseX = 0;
  double _dragStartColWidth = 0.0;

  int _scrollX = 0;
  int _scrollY = 0;

  double _lastClickTime = 0.0;
  int? _lastClickedRow;

  late List<T> _sortedRows;

  DataGrid({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    required this.columns,
    required this.rows,
    this.rowHeight = 28,
    this.headerHeight = 32,
    this.zebraStriping = true,
    this.showGridLines = true,
    this.resizableColumns = true,
    this.sortColumnId,
    this.sortAscending = true,
    this.selectedIndex,
    this.onRowSelected,
    this.onRowDoubleClicked,
    this.onSortChanged,
  }) {
    _sortedRows = List<T>.from(rows);
    if (sortColumnId != null) {
      _applySort();
    }
    _updateDimensions();
  }

  void _updateDimensions() {
    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    }
    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    }
  }

  @override
  bool get isFlexWidth => true;

  @override
  bool get isFlexHeight => true;

  @override
  void onResize(int maxWidth, int maxHeight) {
    width = maxWidth;
    height = maxHeight;
  }

  int get totalGridWidth {
    double sum = 0.0;
    for (final col in columns) {
      sum += col.width;
    }
    return sum.round();
  }

  int get _maxScrollX => math.max(0, totalGridWidth - width);

  int get _maxScrollY {
    final bodyHeight = _sortedRows.length * rowHeight;
    final availableH = height - headerHeight;
    return math.max(0, bodyHeight - availableH);
  }

  void _applySort() {
    if (sortColumnId == null) return;
    final col = columns.firstWhere((c) => c.id == sortColumnId, orElse: () => columns.first);

    _sortedRows.sort((a, b) {
      int cmp = 0;
      if (col.comparator != null) {
        cmp = col.comparator!(a, b);
      } else if (col.cellValue != null) {
        final valA = col.cellValue!(a);
        final valB = col.cellValue!(b);
        // Intentar comparación numérica si ambos son números
        final numA = double.tryParse(valA);
        final numB = double.tryParse(valB);
        if (numA != null && numB != null) {
          cmp = numA.compareTo(numB);
        } else {
          cmp = valA.compareTo(valB);
        }
      }
      return sortAscending ? cmp : -cmp;
    });
  }

  void sortByColumn(String colId) {
    if (sortColumnId == colId) {
      sortAscending = !sortAscending;
    } else {
      sortColumnId = colId;
      sortAscending = true;
    }
    _applySort();
    onSortChanged?.call(sortColumnId!, sortAscending);
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);
    if (!isVisible || !isEnabled) return;

    final mx = input.mouseX.round();
    final my = input.mouseY.round();
    final isInside = mx >= x && mx < x + width && my >= y && my < y + height;

    // Gestión del arrastre para redimensionar columnas
    if (_isDraggingBorder) {
      if (input.isMouseButtonDown(0)) {
        final delta = mx - _dragStartMouseX;
        final col = columns[_draggedBorderIndex];
        col.width = math.max(col.minWidth, _dragStartColWidth + delta);
        return;
      } else {
        _isDraggingBorder = false;
        _draggedBorderIndex = -1;
      }
    }

    _hoveredRowIndex = -1;
    _hoveredHeaderIndex = -1;
    _hoveredResizeBorderIndex = -1;

    if (!isInside) return;

    // Desplazamiento de rueda de ratón (vertical normal, horizontal con Shift)
    final wheel = input.mouseWheelMove;
    if (wheel != 0) {
      if (input.isShiftDown) {
        _scrollX = math.max(0, math.min(_maxScrollX, _scrollX - (wheel * 40).round()));
      } else {
        _scrollY = math.max(0, math.min(_maxScrollY, _scrollY - (wheel * 32).round()));
      }
    }

    final isOverHeader = my >= y && my < y + headerHeight;

    if (isOverHeader) {
      // Detección sobre cabecera y bordes de redimensionamiento
      int currentHeaderX = x - _scrollX;

      for (int i = 0; i < columns.length; i++) {
        final col = columns[i];
        final colW = col.width.round();
        final borderX = currentHeaderX + colW;

        // Detección de borde para redimensionar (±4 px de margen)
        if (resizableColumns && mx >= borderX - 4 && mx <= borderX + 4) {
          _hoveredResizeBorderIndex = i;
          if (input.isMouseButtonPressed(0)) {
            _isDraggingBorder = true;
            _draggedBorderIndex = i;
            _dragStartMouseX = mx;
            _dragStartColWidth = col.width;
            return;
          }
        }

        // Clic en la cabecera para ordenar
        if (mx >= currentHeaderX && mx < currentHeaderX + colW) {
          _hoveredHeaderIndex = i;
          if (col.sortable && input.isMouseButtonPressed(0) && _hoveredResizeBorderIndex == -1) {
            sortByColumn(col.id);
            return;
          }
        }

        currentHeaderX += colW;
      }
    } else {
      // Detección sobre las filas del cuerpo
      final relativeY = my - (y + headerHeight) + _scrollY;
      final rowIndex = relativeY ~/ rowHeight;

      if (rowIndex >= 0 && rowIndex < _sortedRows.length) {
        _hoveredRowIndex = rowIndex;

        if (input.isMouseButtonPressed(0)) {
          final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
          final isDouble = (_lastClickedRow == rowIndex) && (now - _lastClickTime < 0.35);

          selectedIndex = rowIndex;
          final selectedItem = _sortedRows[rowIndex];
          onRowSelected?.call(selectedItem, rowIndex);

          if (isDouble) {
            onRowDoubleClicked?.call(selectedItem, rowIndex);
          }

          _lastClickTime = now;
          _lastClickedRow = rowIndex;
        }
      }
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    final style = currentStyle;
    final bgColor = style.bgColor ?? const ColorRGBA(20, 21, 25, 255);
    final borderColor = style.borderColor ?? const ColorRGBA(42, 44, 52, 255);
    final headerBg = const ColorRGBA(28, 30, 36, 255);
    final headerText = const ColorRGBA(200, 205, 215, 255);
    final zebraColor = const ColorRGBA(24, 25, 30, 255);
    final hoverRowBg = const ColorRGBA(36, 38, 46, 255);
    final selectedRowBg = const ColorRGBA(37, 99, 235, 90);
    final selectedRowBorder = const ColorRGBA(59, 130, 246, 255);
    final cellDefaultText = style.textColor ?? const ColorRGBA(210, 215, 225, 255);
    final gridLineColor = const ColorRGBA(35, 37, 44, 255);

    // Fondo y borde general del DataGrid
    ctx2d.drawRectangle(x, y, width, height, bgColor);
    ctx2d.drawLine(x, y, x + width, y, borderColor);
    ctx2d.drawLine(x, y + height - 1, x + width, y + height - 1, borderColor);

    // 1. Renderizar filas del cuerpo con recorte de tijera
    final bodyY = y + headerHeight;
    final bodyHeight = height - headerHeight;

    ctx2d.beginScissor(x, bodyY, width, bodyHeight);

    for (int r = 0; r < _sortedRows.length; r++) {
      final rowY = bodyY + (r * rowHeight) - _scrollY;
      if (rowY + rowHeight < bodyY || rowY > y + height) continue;

      final isSelected = r == selectedIndex;
      final isHovered = r == _hoveredRowIndex;
      final rowItem = _sortedRows[r];

      // Fondo de fila
      ColorRGBA rowBg = (zebraStriping && r.isOdd) ? zebraColor : bgColor;
      if (isSelected) {
        rowBg = selectedRowBg;
      } else if (isHovered) {
        rowBg = hoverRowBg;
      }

      ctx2d.drawRectangle(x, rowY, width, rowHeight, rowBg);

      if (isSelected) {
        ctx2d.drawRectangle(x, rowY, 3, rowHeight, selectedRowBorder);
      }

      // Línea divisoria horizontal entre filas
      if (showGridLines) {
        ctx2d.drawLine(x, rowY + rowHeight - 1, x + width, rowY + rowHeight - 1, gridLineColor);
      }

      // Renderizar celdas de la fila
      int currentCellX = x - _scrollX;
      for (int c = 0; c < columns.length; c++) {
        final col = columns[c];
        final colW = col.width.round();

        // Solo renderizar celdas dentro del viewport horizontal
        if (currentCellX + colW >= x && currentCellX <= x + width) {
          final cellText = col.cellValue?.call(rowItem) ?? '';
          final cellColor = col.cellTextColor?.call(rowItem) ?? cellDefaultText;

          // Recorte interno de celda
          ctx2d.beginScissor(currentCellX + 4, rowY, colW - 8, rowHeight);

          final textY = rowY + (rowHeight - 13) ~/ 2;
          int textX = currentCellX + 8;

          if (col.alignment == Alignment2D.centerRight || col.alignment == Alignment2D.topRight || col.alignment == Alignment2D.bottomRight) {
            textX = currentCellX + colW - 12 - (cellText.length * 8);
          } else if (col.alignment == Alignment2D.center || col.alignment == Alignment2D.topCenter || col.alignment == Alignment2D.bottomCenter) {
            textX = currentCellX + (colW - (cellText.length * 8)) ~/ 2;
          }

          ctx2d.drawText(cellText, textX, textY, 13, cellColor);
          ctx2d.endScissor();

          // Línea divisoria vertical entre columnas
          if (showGridLines) {
            ctx2d.drawLine(currentCellX + colW - 1, rowY, currentCellX + colW - 1, rowY + rowHeight, gridLineColor);
          }
        }

        currentCellX += colW;
      }
    }

    ctx2d.endScissor();

    // 2. Renderizar Cabecera (anclada arriba, se desplaza horizontalmente con _scrollX)
    ctx2d.drawRectangle(x, y, width, headerHeight, headerBg);
    ctx2d.drawLine(x, y + headerHeight - 1, x + width, y + headerHeight - 1, borderColor);

    ctx2d.beginScissor(x, y, width, headerHeight);

    int currentHeadX = x - _scrollX;

    for (int i = 0; i < columns.length; i++) {
      final col = columns[i];
      final colW = col.width.round();
      final isHeadHovered = i == _hoveredHeaderIndex;
      final isSortedCol = col.id == sortColumnId;

      if (isHeadHovered && col.sortable) {
        ctx2d.drawRectangle(currentHeadX, y, colW, headerHeight - 1, const ColorRGBA(36, 38, 46, 255));
      }

      final headTextY = y + (headerHeight - 13) ~/ 2;
      int headTextX = currentHeadX + 8;

      if (col.alignment == Alignment2D.centerRight || col.alignment == Alignment2D.topRight || col.alignment == Alignment2D.bottomRight) {
        headTextX = currentHeadX + colW - 14 - (col.title.length * 8);
        if (isSortedCol) headTextX -= 16;
      }

      ctx2d.drawText(col.title, headTextX, headTextY, 13, isSortedCol ? const ColorRGBA(255, 255, 255, 255) : headerText);

      // Indicador de ordenamiento (flecha ascendente o descendente)
      if (isSortedCol) {
        final arrowIcon = sortAscending ? Icons.arrow_drop_up : Icons.arrow_drop_down;
        final arrowX = headTextX + (col.title.length * 8) + 4;
        ctx2d.drawIcon(arrowIcon, arrowX, headTextY - 3, 16, const ColorRGBA(96, 165, 250, 255));
      }

      // Divisor vertical entre cabeceras y tirador de redimensionamiento
      final borderX = currentHeadX + colW - 1;
      final isBorderHovered = i == _hoveredResizeBorderIndex || i == _draggedBorderIndex;
      final borderLineColor = isBorderHovered ? const ColorRGBA(96, 165, 250, 255) : borderColor;

      ctx2d.drawLine(borderX, y + 4, borderX, y + headerHeight - 5, borderLineColor);

      currentHeadX += colW;
    }

    ctx2d.endScissor();

    // 3. Barra de desplazamiento vertical
    final totalBodyH = _sortedRows.length * rowHeight;
    if (totalBodyH > bodyHeight) {
      final sbW = 6;
      final sbX = x + width - sbW - 2;
      final thumbH = math.max(20, (bodyHeight * bodyHeight) ~/ totalBodyH);
      final thumbY = bodyY + ((bodyHeight - thumbH) * _scrollY) ~/ (totalBodyH - bodyHeight);

      ctx2d.drawRectangle(sbX, bodyY, sbW, bodyHeight, const ColorRGBA(0, 0, 0, 30));
      ctx2d.drawRectangle(sbX, thumbY, sbW, thumbH, const ColorRGBA(120, 125, 140, 150));
    }

    // 4. Barra de desplazamiento horizontal
    if (totalGridWidth > width) {
      final sbH = 6;
      final sbY = y + height - sbH - 2;
      final thumbW = math.max(20, (width * width) ~/ totalGridWidth);
      final thumbX = x + ((width - thumbW) * _scrollX) ~/ (totalGridWidth - width);

      ctx2d.drawRectangle(x, sbY, width, sbH, const ColorRGBA(0, 0, 0, 30));
      ctx2d.drawRectangle(thumbX, sbY, thumbW, sbH, const ColorRGBA(120, 125, 140, 150));
    }
  }
}

