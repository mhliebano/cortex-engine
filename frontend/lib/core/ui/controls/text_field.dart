import 'dart:math' as math;
import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/icons.dart';
import 'package:frontend/core/ui/text_editing_controller.dart';

/// Componente interactivo de Entrada de Texto (`TextField`) bajo la arquitectura `ControlNode`.
///
/// Soporta:
/// - Edición de texto monolínea y multilínea (TextArea) con auto wrap y scroll vertical.
/// - Edición con cursor parpadeante, posicionamiento por clic en cualquier posición del texto.
/// - Selección de texto por arrastre con el ratón y selección por teclado (`Shift` + flechas/Home/End).
/// - Atajos de portapapeles nativo del sistema operativo:
///   - `Ctrl + C`: Copiar texto seleccionado.
///   - `Ctrl + X`: Cortar texto seleccionado.
///   - `Ctrl + V`: Pegar texto del portapapeles.
///   - `Ctrl + A`: Seleccionar todo el texto.
/// - Reemplazo y borrado atómico de selección al tipear o pulsar Backspace/Delete.
/// - Foco global exclusivo (`_activeFocusedTextField`).
/// - Modo contraseña (`obscureText`), botón de limpiado rápido (`clearable`) e íconos decorativos.
/// - Estilizado dinámico mediante clases CSS (`styleClass` / `layoutClass`).
class TextField extends ControlNode {
  final TextEditingController controller;
  final bool isMultiline;
  String placeholder;
  bool clearable;
  bool obscureText;
  String? prefixIcon;
  String? suffixIcon;
  void Function(String text)? onChanged;
  void Function(String text)? onSubmitted;

  int _cursorIndex = 0;
  double _cursorTimer = 0.0;
  bool _showCursor = true;
  bool _isPasswordVisible = false;
  double _scrollOffsetY = 0.0;

  // Selección de texto
  int? _selectionAnchor;
  int? _selectionCursor;
  bool _isDraggingSelection = false;

  // Temporizadores para autorrepetición de borrado/navegación con teclado
  double _backspaceHoldTime = 0.0;
  double _backspaceRepeatTimer = 0.0;
  double _deleteHoldTime = 0.0;
  double _deleteRepeatTimer = 0.0;

  TextField({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    String text = '',
    TextEditingController? controller,
    this.isMultiline = false,
    this.placeholder = 'Ingresar valor...',
    bool isFocused = false,
    this.clearable = false,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
  }) : controller = controller ?? TextEditingController(text: text) {
    _cursorIndex = this.controller.text.length;
    _updateDimensions();

    if (isFocused) {
      requestFocus();
    } else {
      this.isFocused = false;
    }
  }

  /// Getter para obtener el texto actual desde el controlador.
  String get text => controller.text;

  /// Setter para actualizar el texto en el controlador.
  set text(String value) {
    controller.text = value;
    if (_cursorIndex > value.length) {
      _cursorIndex = value.length;
    }
    clearSelection();
  }

  /// Indica si actualmente existe un rango de texto seleccionado.
  bool get hasSelection =>
      _selectionAnchor != null &&
      _selectionCursor != null &&
      _selectionAnchor != _selectionCursor;

  /// Índice inicial (inclusivo) de la selección actual.
  int get selectionStart => _selectionAnchor == null
      ? _cursorIndex
      : math.min(_selectionAnchor!, _selectionCursor ?? _cursorIndex);

  /// Índice final (exclusivo) de la selección actual.
  int get selectionEnd => _selectionAnchor == null
      ? _cursorIndex
      : math.max(_selectionAnchor!, _selectionCursor ?? _cursorIndex);

  /// Obtiene la cadena de texto actualmente seleccionada.
  String get selectedText {
    if (!hasSelection) return '';
    final cur = controller.text;
    final start = selectionStart.clamp(0, cur.length);
    final end = selectionEnd.clamp(0, cur.length);
    return cur.substring(start, end);
  }

  /// Limpia la selección activa.
  void clearSelection() {
    _selectionAnchor = null;
    _selectionCursor = null;
  }

  /// Selecciona la totalidad del texto presente en el campo.
  void selectAll() {
    _selectionAnchor = 0;
    _selectionCursor = controller.text.length;
    _cursorIndex = controller.text.length;
    _showCursor = true;
    _cursorTimer = 0.0;
  }

  /// Elimina el rango actualmente seleccionado y posiciona el cursor al inicio de la selección.
  void _deleteSelection() {
    if (!hasSelection) return;
    final cur = controller.text;
    final start = selectionStart.clamp(0, cur.length);
    final end = selectionEnd.clamp(0, cur.length);
    controller.text = cur.substring(0, start) + cur.substring(end);
    _cursorIndex = start;
    clearSelection();
  }

  /// Instancia estática del TextField enfocado activamente en toda la aplicación.
  static TextField? _activeFocusedTextField;

  /// Obtiene el TextField actualmente enfocado.
  static TextField? get activeFocusedTextField => _activeFocusedTextField;

  /// Limpia el foco activo de cualquier TextField en la aplicación.
  static void clearActiveFocus() {
    if (_activeFocusedTextField != null) {
      _activeFocusedTextField!.unfocus();
    }
  }

  /// Concede el foco teclado de forma exclusiva a este campo.
  void requestFocus() {
    if (_activeFocusedTextField != null && _activeFocusedTextField != this) {
      _activeFocusedTextField!.isFocused = false;
    }
    isFocused = true;
    _activeFocusedTextField = this;
    _showCursor = true;
    _cursorTimer = 0.0;
  }

  /// Quita el foco de teclado de este campo.
  void unfocus() {
    isFocused = false;
    clearSelection();
    if (_activeFocusedTextField == this) {
      _activeFocusedTextField = null;
    }
  }

  @override
  void onResize(int maxWidth, int maxHeight) {
    final layout = currentLayout;
    int requestedWidth;
    final wRule = layout.width;
    if (wRule != null) {
      if (wRule == double.infinity) {
        requestedWidth = maxWidth;
      } else if (wRule > 0.0 && wRule <= 1.0) {
        requestedWidth = (maxWidth * wRule).round();
      } else if (wRule.isFinite) {
        requestedWidth = wRule.round();
      } else {
        requestedWidth = 220;
      }
    } else {
      requestedWidth = 220;
    }

    final defaultHeight = isMultiline ? 100 : 34;
    int requestedHeight;
    final hRule = layout.height;
    if (hRule != null) {
      if (hRule == double.infinity) {
        requestedHeight = maxHeight;
      } else if (hRule > 0.0 && hRule <= 1.0) {
        requestedHeight = (maxHeight * hRule).round();
      } else if (hRule.isFinite) {
        requestedHeight = hRule.round();
      } else {
        requestedHeight = defaultHeight;
      }
    } else {
      requestedHeight = defaultHeight;
    }

    width = (maxWidth > 0 && requestedWidth > maxWidth) ? maxWidth : requestedWidth;
    height = (maxHeight > 0 && requestedHeight > maxHeight) ? maxHeight : requestedHeight;
  }

  void _updateDimensions() {
    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    } else if (!isFlexWidth && width <= 0) {
      width = 220;
    }

    final defaultHeight = isMultiline ? 100 : 34;
    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else if (!isFlexHeight && height <= 0) {
      height = defaultHeight;
    }
  }

  @override
  void onMouseDown() {
    super.onMouseDown();
    if (!isVisible || !isEnabled) return;
    requestFocus();
  }

  int _getTextIndexFromMouse(
    double mx,
    double my,
    String displayText,
    int leftPadding,
    int scrollOffsetX,
    double charWidth,
  ) {
    if (displayText.isEmpty || charWidth <= 0) return 0;
    final localX = mx - (x + leftPadding) + scrollOffsetX;
    if (localX <= 0) return 0;
    final idx = (localX / charWidth).round();
    return idx.clamp(0, displayText.length);
  }

  int _getMultilineIndexFromMouse(
    double mx,
    double my,
    String displayText,
    int leftPadding,
    double scrollOffsetY,
    double charWidth,
    int lineHeight,
    int textAreaWidth,
  ) {
    if (displayText.isEmpty) return 0;
    final lines = _getWrappedLines(displayText, textAreaWidth, charWidth);
    final textY = y + 8;
    final localY = my - textY + scrollOffsetY;
    int clickedRow = (localY / lineHeight).floor();
    if (clickedRow < 0) clickedRow = 0;
    if (clickedRow >= lines.length) clickedRow = lines.length - 1;

    final localX = mx - (x + leftPadding);
    int clickedCol = (localX / charWidth).round();
    if (clickedCol < 0) clickedCol = 0;
    if (clickedCol > lines[clickedRow].length) clickedCol = lines[clickedRow].length;

    return _getCursorIndexFrom2D(
      displayText,
      clickedRow,
      clickedCol,
      textAreaWidth,
      charWidth,
    );
  }

  int _getCursorIndexFrom2D(
    String text,
    int targetRow,
    int targetCol,
    int maxWidth,
    double charWidth,
  ) {
    final rawLines = text.split('\n');
    final maxCharsPerLine = (maxWidth > 0 && charWidth > 0)
        ? (maxWidth / charWidth).floor()
        : 0;

    int currentPos = 0;
    int currentRow = 0;

    for (int p = 0; p < rawLines.length; p++) {
      final rawLine = rawLines[p];
      final isLastParagraph = (p == rawLines.length - 1);

      if (rawLine.isEmpty) {
        if (currentRow == targetRow) {
          return currentPos;
        }
        currentPos += 1;
        currentRow += 1;
        continue;
      }

      if (maxCharsPerLine <= 0 || rawLine.length <= maxCharsPerLine) {
        if (currentRow == targetRow) {
          return (currentPos + targetCol).clamp(0, currentPos + rawLine.length);
        }
        currentPos += rawLine.length;
        if (!isLastParagraph) currentPos += 1;
        currentRow += 1;
      } else {
        int start = 0;
        while (start < rawLine.length) {
          int end = start + maxCharsPerLine;
          if (end > rawLine.length) end = rawLine.length;
          final chunkLen = end - start;
          final isLastChunk = (end == rawLine.length);

          if (currentRow == targetRow) {
            return (currentPos + targetCol).clamp(0, currentPos + chunkLen);
          }
          currentPos += chunkLen;
          if (isLastChunk && !isLastParagraph) currentPos += 1;
          currentRow += 1;
          start = end;
        }
      }
    }
    return currentPos.clamp(0, text.length);
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);

    if (!isVisible || !isEnabled) {
      if (isFocused) unfocus();
      return;
    }

    _updateDimensions();
    isHovered = input.isHovering(x, y, width, height);

    // Padding y dimensiones de cálculo
    int leftPadding = 12;
    if (prefixIcon != null && prefixIcon!.isNotEmpty) {
      leftPadding = 34;
    }
    int rightPadding = 12;
    if (clearable ||
        obscureText ||
        (suffixIcon != null && suffixIcon!.isNotEmpty)) {
      rightPadding = 30;
    }
    final textAreaWidth = width - leftPadding - rightPadding;
    final fontSize = currentStyle.fontSize ?? 14;
    final charWidth = fontSize * 0.55;
    final lineHeight = (fontSize * 1.5).round();

    final String rawText = controller.text;
    final String displayText = obscureText && !_isPasswordVisible
        ? '•' * rawText.length
        : rawText;

    int scrollOffsetX = 0;
    if (!isMultiline) {
      final safeCursor = _cursorIndex.clamp(0, displayText.length);
      final textBeforeCursor = displayText.substring(0, safeCursor);
      final cursorXOffset = (textBeforeCursor.length * charWidth).toInt();
      if (textAreaWidth > 0 && cursorXOffset > textAreaWidth - 14) {
        scrollOffsetX = cursorXOffset - (textAreaWidth - 14);
      }
    }

    // 1. Manejo de clics del ratón (posicionamiento de cursor y arrastre de selección)
    if (input.isMouseButtonPressed(MouseButtons.left)) {
      if (isHovered) {
        onMouseDown();

        final rightButtonX = x + width - 28;
        final mx = input.mouseX;
        final my = input.mouseY;

        if (clearable &&
            controller.text.isNotEmpty &&
            mx >= rightButtonX &&
            mx <= rightButtonX + 24 &&
            my >= y &&
            my <= y + height) {
          controller.text = '';
          _cursorIndex = 0;
          clearSelection();
          onChanged?.call('');
          requestFocus();
          return;
        }

        if (obscureText &&
            mx >= rightButtonX &&
            mx <= rightButtonX + 24 &&
            my >= y &&
            my <= y + height) {
          _isPasswordVisible = !_isPasswordVisible;
          requestFocus();
          return;
        }

        // Posicionar cursor en las coordenadas exactas de clic
        final int clickedIndex;
        if (isMultiline) {
          clickedIndex = _getMultilineIndexFromMouse(
            mx,
            my,
            displayText,
            leftPadding,
            _scrollOffsetY,
            charWidth,
            lineHeight,
            textAreaWidth,
          );
        } else {
          clickedIndex = _getTextIndexFromMouse(
            mx,
            my,
            displayText,
            leftPadding,
            scrollOffsetX,
            charWidth,
          );
        }

        _cursorIndex = clickedIndex;
        _showCursor = true;
        _cursorTimer = 0.0;

        if (input.isShiftDown && _selectionAnchor != null) {
          _selectionCursor = clickedIndex;
        } else {
          _selectionAnchor = clickedIndex;
          _selectionCursor = clickedIndex;
        }
        _isDraggingSelection = true;
      } else if (isFocused) {
        unfocus();
      }
    }

    // Arrastre con ratón para expandir selección
    if (_isDraggingSelection && input.isMouseButtonDown(MouseButtons.left)) {
      final mx = input.mouseX;
      final my = input.mouseY;
      final int dragIndex;
      if (isMultiline) {
        dragIndex = _getMultilineIndexFromMouse(
          mx,
          my,
          displayText,
          leftPadding,
          _scrollOffsetY,
          charWidth,
          lineHeight,
          textAreaWidth,
        );
      } else {
        dragIndex = _getTextIndexFromMouse(
          mx,
          my,
          displayText,
          leftPadding,
          scrollOffsetX,
          charWidth,
        );
      }

      _cursorIndex = dragIndex;
      _selectionCursor = dragIndex;
      _showCursor = true;
      _cursorTimer = 0.0;
    }

    if (input.isMouseButtonReleased(MouseButtons.left)) {
      _isDraggingSelection = false;
      if (_selectionAnchor == _selectionCursor) {
        clearSelection();
      }
    }

    // Sincronización estricta de foco global exclusivo
    if (_activeFocusedTextField != this && isFocused) {
      isFocused = false;
      clearSelection();
    }

    if (isFocused) {
      // 2. Parpadeo del cursor
      _cursorTimer += dt;
      if (_cursorTimer >= 0.45) {
        _showCursor = !_showCursor;
        _cursorTimer = 0.0;
      }

      bool textChanged = false;
      String currentText = controller.text;

      // Garantizar que _cursorIndex se mantenga dentro de los límites válidos
      if (_cursorIndex < 0) _cursorIndex = 0;
      if (_cursorIndex > currentText.length) _cursorIndex = currentText.length;

      // 3. Atajos de Teclado con Control (Ctrl+A, Ctrl+C, Ctrl+X, Ctrl+V)
      if (input.isControlDown) {
        // Ctrl + A: Seleccionar Todo
        if (input.isKeyPressed(Keys.a)) {
          selectAll();
        }

        // Ctrl + C: Copiar al portapapeles
        if (input.isKeyPressed(Keys.c)) {
          if (hasSelection) {
            input.setClipboardText(selectedText);
          }
        }

        // Ctrl + X: Cortar al portapapeles
        if (input.isKeyPressed(Keys.x)) {
          if (hasSelection) {
            input.setClipboardText(selectedText);
            _deleteSelection();
            currentText = controller.text;
            textChanged = true;
            _showCursor = true;
            _cursorTimer = 0.0;
          }
        }

        // Ctrl + V: Pegar desde portapapeles
        if (input.isKeyPressed(Keys.v)) {
          final clipText = input.getClipboardText();
          if (clipText.isNotEmpty) {
            if (hasSelection) {
              _deleteSelection();
              currentText = controller.text;
            }
            controller.text = currentText.substring(0, _cursorIndex) +
                clipText +
                currentText.substring(_cursorIndex);
            _cursorIndex += clipText.length;
            currentText = controller.text;
            clearSelection();
            textChanged = true;
            _showCursor = true;
            _cursorTimer = 0.0;
          }
        }
      }

      // 4. Intercepción de Tecla Enter (Keys.enter = 257)
      if (input.isKeyPressed(Keys.enter)) {
        if (hasSelection) {
          _deleteSelection();
          currentText = controller.text;
          textChanged = true;
        }
        if (!isMultiline) {
          onSubmitted?.call(currentText);
        } else {
          controller.text =
              '${currentText.substring(0, _cursorIndex)}\n${currentText.substring(_cursorIndex)}';
          _cursorIndex += 1;
          currentText = controller.text;
          textChanged = true;
          _showCursor = true;
          _cursorTimer = 0.0;
        }
      }

      // 5. Navegación por Teclas de Dirección con soporte de selección (Shift)
      if (input.isKeyPressed(Keys.left)) {
        if (input.isShiftDown) {
          _selectionAnchor ??= _cursorIndex;
          if (_cursorIndex > 0) _cursorIndex--;
          _selectionCursor = _cursorIndex;
        } else {
          if (hasSelection) {
            _cursorIndex = selectionStart;
            clearSelection();
          } else if (_cursorIndex > 0) {
            _cursorIndex--;
          }
        }
        _showCursor = true;
        _cursorTimer = 0.0;
      }

      if (input.isKeyPressed(Keys.right)) {
        if (input.isShiftDown) {
          _selectionAnchor ??= _cursorIndex;
          if (_cursorIndex < currentText.length) _cursorIndex++;
          _selectionCursor = _cursorIndex;
        } else {
          if (hasSelection) {
            _cursorIndex = selectionEnd;
            clearSelection();
          } else if (_cursorIndex < currentText.length) {
            _cursorIndex++;
          }
        }
        _showCursor = true;
        _cursorTimer = 0.0;
      }

      if (input.isKeyPressed(Keys.home)) {
        if (input.isShiftDown) {
          _selectionAnchor ??= _cursorIndex;
          _cursorIndex = 0;
          _selectionCursor = 0;
        } else {
          clearSelection();
          _cursorIndex = 0;
        }
        _showCursor = true;
        _cursorTimer = 0.0;
      }

      if (input.isKeyPressed(Keys.end)) {
        if (input.isShiftDown) {
          _selectionAnchor ??= _cursorIndex;
          _cursorIndex = currentText.length;
          _selectionCursor = currentText.length;
        } else {
          clearSelection();
          _cursorIndex = currentText.length;
        }
        _showCursor = true;
        _cursorTimer = 0.0;
      }

      // 6. Captura de borrado `Backspace` (Keys.backspace = 259)
      bool triggerBackspace = false;
      if (input.isKeyPressed(Keys.backspace)) {
        triggerBackspace = true;
        _backspaceHoldTime = 0.0;
        _backspaceRepeatTimer = 0.0;
      } else if (input.isKeyDown(Keys.backspace)) {
        _backspaceHoldTime += dt;
        if (_backspaceHoldTime >= 0.35) {
          _backspaceRepeatTimer += dt;
          if (_backspaceRepeatTimer >= 0.04) {
            triggerBackspace = true;
            _backspaceRepeatTimer = 0.0;
          }
        }
      } else {
        _backspaceHoldTime = 0.0;
        _backspaceRepeatTimer = 0.0;
      }

      if (triggerBackspace) {
        if (hasSelection) {
          _deleteSelection();
          currentText = controller.text;
          textChanged = true;
          _showCursor = true;
          _cursorTimer = 0.0;
        } else if (_cursorIndex > 0 && currentText.isNotEmpty) {
          controller.text =
              currentText.substring(0, _cursorIndex - 1) +
              currentText.substring(_cursorIndex);
          _cursorIndex--;
          currentText = controller.text;
          textChanged = true;
          _showCursor = true;
          _cursorTimer = 0.0;
        }
      }

      // 7. Captura de borrado hacia adelante `Delete` (Keys.delete = 261)
      bool triggerDelete = false;
      if (input.isKeyPressed(Keys.delete)) {
        triggerDelete = true;
        _deleteHoldTime = 0.0;
        _deleteRepeatTimer = 0.0;
      } else if (input.isKeyDown(Keys.delete)) {
        _deleteHoldTime += dt;
        if (_deleteHoldTime >= 0.35) {
          _deleteRepeatTimer += dt;
          if (_deleteRepeatTimer >= 0.04) {
            triggerDelete = true;
            _deleteRepeatTimer = 0.0;
          }
        }
      } else {
        _deleteHoldTime = 0.0;
        _deleteRepeatTimer = 0.0;
      }

      if (triggerDelete) {
        if (hasSelection) {
          _deleteSelection();
          currentText = controller.text;
          textChanged = true;
          _showCursor = true;
          _cursorTimer = 0.0;
        } else if (_cursorIndex < currentText.length) {
          controller.text =
              currentText.substring(0, _cursorIndex) +
              currentText.substring(_cursorIndex + 1);
          currentText = controller.text;
          textChanged = true;
          _showCursor = true;
          _cursorTimer = 0.0;
        }
      }

      // 8. Cola de captura de caracteres imprimibles (Unicode >= 32)
      // Se ignora la entrada tipada si Control está presionado para no duplicar atajos
      int charCode = input.getCharPressed();
      while (charCode > 0) {
        if (!input.isControlDown && ((charCode >= 32 && charCode <= 126) || charCode >= 160)) {
          if (hasSelection) {
            _deleteSelection();
            currentText = controller.text;
          }
          final charStr = String.fromCharCode(charCode);
          controller.text =
              currentText.substring(0, _cursorIndex) +
              charStr +
              currentText.substring(_cursorIndex);
          _cursorIndex += charStr.length;
          currentText = controller.text;
          textChanged = true;
          _showCursor = true;
          _cursorTimer = 0.0;
        }
        charCode = input.getCharPressed();
      }

      if (textChanged) {
        onChanged?.call(controller.text);
      }
    } else {
      _showCursor = false;
    }
  }

  /// Divide el texto en párrafos y corta matemáticamente las líneas si superan [maxWidth].
  List<String> _getWrappedLines(String text, int maxWidth, double charWidth) {
    if (text.isEmpty) return [''];
    final rawLines = text.split('\n');
    if (maxWidth <= 0 || charWidth <= 0) return rawLines;

    final maxCharsPerLine = (maxWidth / charWidth).floor();
    if (maxCharsPerLine <= 0) return rawLines;

    final List<String> wrapped = [];
    for (final rawLine in rawLines) {
      if (rawLine.isEmpty) {
        wrapped.add('');
        continue;
      }
      int start = 0;
      while (start < rawLine.length) {
        int end = start + maxCharsPerLine;
        if (end > rawLine.length) {
          end = rawLine.length;
        }
        wrapped.add(rawLine.substring(start, end));
        start = end;
      }
    }
    return wrapped;
  }

  /// Calcula la fila y columna (caracteres) en el espacio 2D envuelto para el [cursorIndex].
  (int row, int col) _getCursor2DPosition(
    String text,
    int cursorIndex,
    int maxWidth,
    double charWidth,
  ) {
    final safeCursor = cursorIndex.clamp(0, text.length);
    final rawLines = text.split('\n');
    final maxCharsPerLine = (maxWidth > 0 && charWidth > 0)
        ? (maxWidth / charWidth).floor()
        : 0;

    int currentPos = 0;
    int currentRow = 0;

    for (int p = 0; p < rawLines.length; p++) {
      final rawLine = rawLines[p];
      final isLastParagraph = (p == rawLines.length - 1);

      if (rawLine.isEmpty) {
        if (safeCursor == currentPos) {
          return (currentRow, 0);
        }
        currentPos += 1;
        currentRow += 1;
        continue;
      }

      if (maxCharsPerLine <= 0 || rawLine.length <= maxCharsPerLine) {
        final lineLen = rawLine.length;
        if (safeCursor >= currentPos && safeCursor <= currentPos + lineLen) {
          return (currentRow, safeCursor - currentPos);
        }
        currentPos += lineLen;
        if (!isLastParagraph) {
          if (safeCursor == currentPos) {
            return (currentRow, lineLen);
          }
          currentPos += 1;
        }
        currentRow += 1;
      } else {
        int start = 0;
        while (start < rawLine.length) {
          int end = start + maxCharsPerLine;
          if (end > rawLine.length) {
            end = rawLine.length;
          }
          final chunkLen = end - start;
          final isLastChunkOfParagraph = (end == rawLine.length);

          if (safeCursor >= currentPos && safeCursor <= currentPos + chunkLen) {
            return (currentRow, safeCursor - currentPos);
          }
          currentPos += chunkLen;
          if (isLastChunkOfParagraph && !isLastParagraph) {
            if (safeCursor == currentPos) {
              return (currentRow, chunkLen);
            }
            currentPos += 1;
          }
          currentRow += 1;
          start = end;
        }
      }
    }

    return (currentRow > 0 ? currentRow - 1 : 0, 0);
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    _updateDimensions();

    final style = currentStyle;
    final borderRadius = style.borderRadius ?? 0.0;
    final fontSize = style.fontSize ?? 14;
    final textColor = style.textColor ?? ColorRGBA.white;

    final fillBg = isEnabled
        ? (style.bgColor ?? const ColorRGBA(22, 27, 36))
        : const ColorRGBA(16, 20, 26);

    final borderColor = isFocused
        ? (style.accentColor ?? ColorRGBA.accentBlue)
        : (isHovered
              ? (style.borderColor ?? const ColorRGBA(90, 110, 135))
              : (style.borderColor ?? const ColorRGBA(60, 70, 85)));

    // 1. Dibujar contenedor del campo
    if (borderRadius > 0) {
      ctx2d.drawRoundRect(x, y, width, height, borderRadius, color: fillBg);
      ctx2d.drawRoundRectLines(
        x,
        y,
        width,
        height,
        borderRadius,
        color: borderColor,
      );
    } else {
      ctx2d.drawPanel(
        x,
        y,
        width,
        height,
        bgColor: fillBg,
        borderColor: borderColor,
      );
    }

    // 2. Calcular padding interior
    int leftPadding = 12;
    final iconY = isMultiline ? y + 8 : y + (height ~/ 4);

    if (prefixIcon != null && prefixIcon!.isNotEmpty) {
      leftPadding = 34;
      ctx2d.drawText(
        prefixIcon!,
        x + 10,
        iconY,
        16,
        const ColorRGBA(140, 155, 175),
      );
    }

    int rightPadding = 12;
    if (clearable ||
        obscureText ||
        (suffixIcon != null && suffixIcon!.isNotEmpty)) {
      rightPadding = 30;
    }

    final String rawText = controller.text;
    final String displayText = obscureText && !_isPasswordVisible
        ? '•' * rawText.length
        : rawText;

    final textY = isMultiline ? y + 8 : y + (height ~/ 4);
    final textAreaWidth = width - leftPadding - rightPadding;
    final textAreaHeight = isMultiline ? height - 16 : height;

    if (textAreaWidth > 0 && textAreaHeight > 0) {
      ctx2d.beginScissor(
        x + leftPadding,
        isMultiline ? y + 8 : y,
        textAreaWidth,
        textAreaHeight,
      );

      final charWidth = fontSize * 0.55;
      final lineHeight = (fontSize * 1.5).round();

      if (isMultiline) {
        final lines = _getWrappedLines(displayText, textAreaWidth, charWidth);
        final (cursorRow, cursorCol) = _getCursor2DPosition(
          displayText,
          _cursorIndex,
          textAreaWidth,
          charWidth,
        );

        // Actualizar _scrollOffsetY dinámicamente si el cursor supera los límites visibles
        final cursorRelY = cursorRow * lineHeight;
        if (cursorRelY + lineHeight > _scrollOffsetY + textAreaHeight) {
          _scrollOffsetY =
              (cursorRelY + lineHeight - textAreaHeight).toDouble();
        } else if (cursorRelY < _scrollOffsetY) {
          _scrollOffsetY = cursorRelY.toDouble();
        }
        if (_scrollOffsetY < 0.0) _scrollOffsetY = 0.0;

        final textColorToUse = isEnabled
            ? textColor
            : const ColorRGBA(110, 120, 135);

        if (rawText.isEmpty) {
          ctx2d.drawText(
            placeholder,
            x + leftPadding,
            textY - _scrollOffsetY.toInt(),
            fontSize,
            const ColorRGBA(100, 115, 130),
          );

          if (isFocused && _showCursor) {
            ctx2d.drawText(
              '|',
              x + leftPadding - 2,
              textY - _scrollOffsetY.toInt(),
              fontSize,
              ColorRGBA.accentBlue,
            );
          }
        } else {
          // Renderizar sombreado de selección en multilínea
          if (hasSelection) {
            final selStart = selectionStart.clamp(0, displayText.length);
            final selEnd = selectionEnd.clamp(0, displayText.length);

            int charAccum = 0;
            for (int i = 0; i < lines.length; i++) {
              final line = lines[i];
              final lineStart = charAccum;
              final lineEnd = lineStart + line.length;

              final interStart = math.max(lineStart, selStart);
              final interEnd = math.min(lineEnd, selEnd);

              if (interStart < interEnd) {
                final col1 = interStart - lineStart;
                final col2 = interEnd - lineStart;
                final selX1 = x + leftPadding + (col1 * charWidth).toInt();
                final selX2 = x + leftPadding + (col2 * charWidth).toInt();
                final lineY = textY + (i * lineHeight) - _scrollOffsetY.toInt();

                ctx2d.drawRect(
                  selX1,
                  lineY,
                  math.max(2, selX2 - selX1),
                  lineHeight,
                  const ColorRGBA(50, 115, 220, 140),
                );
              }
              charAccum = lineEnd;
            }
          }

          for (int i = 0; i < lines.length; i++) {
            final lineY = textY + (i * lineHeight) - _scrollOffsetY.toInt();
            ctx2d.drawText(
              lines[i],
              x + leftPadding,
              lineY,
              fontSize,
              textColorToUse,
            );
          }

          if (isFocused && _showCursor) {
            final cursorX = x + leftPadding + (cursorCol * charWidth).toInt();
            final cursorY =
                textY + (cursorRow * lineHeight) - _scrollOffsetY.toInt();
            ctx2d.drawText(
              '|',
              cursorX - 2,
              cursorY,
              fontSize,
              ColorRGBA.accentBlue,
            );
          }
        }
      } else {
        // Modo monolínea
        final safeCursor = _cursorIndex.clamp(0, displayText.length);
        final textBeforeCursor = displayText.substring(0, safeCursor);
        final cursorXOffset = (textBeforeCursor.length * charWidth).toInt();

        int scrollOffsetX = 0;
        if (cursorXOffset > textAreaWidth - 14) {
          scrollOffsetX = cursorXOffset - (textAreaWidth - 14);
        }

        final renderTextX = x + leftPadding - scrollOffsetX;

        if (rawText.isEmpty) {
          ctx2d.drawText(
            placeholder,
            renderTextX,
            textY,
            fontSize,
            const ColorRGBA(100, 115, 130),
          );

          if (isFocused && _showCursor) {
            ctx2d.drawText(
              '|',
              renderTextX - 2,
              textY,
              fontSize,
              ColorRGBA.accentBlue,
            );
          }
        } else {
          // Renderizar sombreado de selección en monolínea
          if (hasSelection) {
            final start = selectionStart.clamp(0, displayText.length);
            final end = selectionEnd.clamp(0, displayText.length);
            final selX1 = renderTextX + (start * charWidth).toInt();
            final selX2 = renderTextX + (end * charWidth).toInt();
            final selW = selX2 - selX1;
            if (selW > 0) {
              ctx2d.drawRect(
                selX1,
                textY - 2,
                selW,
                (fontSize * 1.35).round(),
                const ColorRGBA(50, 115, 220, 140),
              );
            }
          }

          final textColorToUse = isEnabled
              ? textColor
              : const ColorRGBA(110, 120, 135);
          ctx2d.drawText(
            displayText,
            renderTextX,
            textY,
            fontSize,
            textColorToUse,
          );

          if (isFocused && _showCursor) {
            final cursorX = renderTextX + cursorXOffset;
            ctx2d.drawText(
              '|',
              cursorX - 2,
              textY,
              fontSize,
              ColorRGBA.accentBlue,
            );
          }
        }
      }

      ctx2d.endScissor();
    }

    // 3. Renderizar ícono de acción derecho (Botón Limpiar 'X' o Alternar Contraseña Eye)
    final rightIconX = x + width - rightPadding + 4;
    if (clearable && rawText.isNotEmpty) {
      ctx2d.drawText(
        Icons.close.glyph,
        rightIconX,
        iconY,
        16,
        const ColorRGBA(160, 175, 195),
      );
    } else if (obscureText) {
      final eyeIcon = _isPasswordVisible
          ? Icons.visibility_off.glyph
          : Icons.visibility.glyph;
      ctx2d.drawText(
        eyeIcon,
        rightIconX,
        iconY,
        16,
        const ColorRGBA(160, 175, 195),
      );
    } else if (suffixIcon != null && suffixIcon!.isNotEmpty) {
      ctx2d.drawText(
        suffixIcon!,
        rightIconX,
        iconY,
        16,
        const ColorRGBA(140, 155, 175),
      );
    }
  }

  @override
  Map<String, dynamic>? exportState() {
    return {
      'text': controller.text,
      'isFocused': isFocused,
      'cursorIndex': _cursorIndex,
      'selectionAnchor': _selectionAnchor,
      'selectionCursor': _selectionCursor,
      'isPasswordVisible': _isPasswordVisible,
      'scrollOffsetY': _scrollOffsetY,
      'backspaceHoldTime': _backspaceHoldTime,
      'backspaceRepeatTimer': _backspaceRepeatTimer,
      'deleteHoldTime': _deleteHoldTime,
      'deleteRepeatTimer': _deleteRepeatTimer,
    };
  }

  @override
  void importState(Map<String, dynamic> state) {
    bool restoredFocused = false;
    if (state.containsKey('isFocused')) {
      restoredFocused = state['isFocused'] as bool;
      if (restoredFocused) {
        requestFocus();
      } else {
        unfocus();
      }
    }

    if (state.containsKey('text')) {
      controller.text = state['text'] as String;
    }

    if (state.containsKey('cursorIndex')) {
      _cursorIndex = (state['cursorIndex'] as int).clamp(
        0,
        controller.text.length,
      );
    }
    if (state.containsKey('selectionAnchor')) {
      _selectionAnchor = state['selectionAnchor'] as int?;
    }
    if (state.containsKey('selectionCursor')) {
      _selectionCursor = state['selectionCursor'] as int?;
    }
    if (state.containsKey('isPasswordVisible')) {
      _isPasswordVisible = state['isPasswordVisible'] as bool;
    }
    if (state.containsKey('scrollOffsetY')) {
      _scrollOffsetY = (state['scrollOffsetY'] as num).toDouble();
    }
    if (state.containsKey('backspaceHoldTime')) {
      _backspaceHoldTime = (state['backspaceHoldTime'] as num).toDouble();
    }
    if (state.containsKey('backspaceRepeatTimer')) {
      _backspaceRepeatTimer = (state['backspaceRepeatTimer'] as num).toDouble();
    }
    if (state.containsKey('deleteHoldTime')) {
      _deleteHoldTime = (state['deleteHoldTime'] as num).toDouble();
    }
    if (state.containsKey('deleteRepeatTimer')) {
      _deleteRepeatTimer = (state['deleteRepeatTimer'] as num).toDouble();
    }
  }
}
