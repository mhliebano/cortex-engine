import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/icons.dart';
import 'package:frontend/core/ui/text_editing_controller.dart';

/// Componente interactivo de Entrada de Texto (`TextField`) bajo la arquitectura `ControlNode`.
///
/// Soporta:
/// - Edición de texto con cursor parpadeante, navegación por flechas (Home/End) y borrado (Backspace/Delete con auto-repeat).
/// - Foco global exclusivo (`_activeFocusedTextField`).
/// - Modo contraseña (`obscureText`), botón de limpiado rápido (`clearable`) e íconos decorativos.
/// - Estilizado dinámico mediante clases CSS (`className` / `currentStyle`).
class TextField extends ControlNode {
  final TextEditingController controller;
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

  // Temporizadores para autorrepetición de borrado/navegación con teclado
  double _backspaceHoldTime = 0.0;
  double _backspaceRepeatTimer = 0.0;
  double _deleteHoldTime = 0.0;
  double _deleteRepeatTimer = 0.0;

  TextField({
    super.key,
    super.isVisible,
    super.className,
    super.isEnabled = true,
    String text = '',
    TextEditingController? controller,
    this.placeholder = 'Ingresar valor...',
    bool isFocused = false,
    this.clearable = false,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    int width = 0,
    int height = 0,
  }) : controller = controller ?? TextEditingController(text: text) {
    _cursorIndex = this.controller.text.length;
    this.width = width;
    this.height = height;
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
    if (_activeFocusedTextField == this) {
      _activeFocusedTextField = null;
    }
  }

  void _updateDimensions() {
    final style = currentStyle;
    if (style.width != null) {
      width = style.width!;
    } else if (width <= 0) {
      width = 220;
    }

    if (style.height != null) {
      height = style.height!;
    } else if (height <= 0) {
      height = 34;
    }
  }

  @override
  void onMouseDown() {
    super.onMouseDown();
    if (!isVisible || !isEnabled) return;
    requestFocus();
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

    // 1. Manejo de clics y detección de acción en íconos o área del control
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

        _cursorIndex = controller.text.length;
      } else if (isFocused) {
        unfocus();
      }
    }

    // Sincronización estricta de foco global exclusivo
    if (_activeFocusedTextField != this && isFocused) {
      isFocused = false;
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

      // 3. Confirmación con Enter (Key 257)
      if (input.isKeyPressed(257)) {
        onSubmitted?.call(currentText);
      }

      // 4. Navegación por Teclas de Dirección (Flecha Izq=263, Flecha Der=262, Home=268, End=269)
      if (input.isKeyPressed(263) && _cursorIndex > 0) {
        _cursorIndex--;
        _showCursor = true;
        _cursorTimer = 0.0;
      }
      if (input.isKeyPressed(262) && _cursorIndex < currentText.length) {
        _cursorIndex++;
        _showCursor = true;
        _cursorTimer = 0.0;
      }
      if (input.isKeyPressed(268)) {
        _cursorIndex = 0;
        _showCursor = true;
        _cursorTimer = 0.0;
      }
      if (input.isKeyPressed(269)) {
        _cursorIndex = currentText.length;
        _showCursor = true;
        _cursorTimer = 0.0;
      }

      // 5. Captura de borrado `Backspace` (Key 259) con soporte para pulsación simple y repetición continua
      bool triggerBackspace = false;
      if (input.isKeyPressed(259)) {
        triggerBackspace = true;
        _backspaceHoldTime = 0.0;
        _backspaceRepeatTimer = 0.0;
      } else if (input.isKeyDown(259)) {
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

      if (triggerBackspace && _cursorIndex > 0 && currentText.isNotEmpty) {
        controller.text =
            currentText.substring(0, _cursorIndex - 1) +
            currentText.substring(_cursorIndex);
        _cursorIndex--;
        currentText = controller.text;
        textChanged = true;
        _showCursor = true;
        _cursorTimer = 0.0;
      }

      // 6. Captura de borrado hacia adelante `Delete` (Key 261)
      bool triggerDelete = false;
      if (input.isKeyPressed(261)) {
        triggerDelete = true;
        _deleteHoldTime = 0.0;
        _deleteRepeatTimer = 0.0;
      } else if (input.isKeyDown(261)) {
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

      if (triggerDelete && _cursorIndex < currentText.length) {
        controller.text =
            currentText.substring(0, _cursorIndex) +
            currentText.substring(_cursorIndex + 1);
        currentText = controller.text;
        textChanged = true;
        _showCursor = true;
        _cursorTimer = 0.0;
      }

      // 7. Cola de captura de caracteres imprimibles (Unicode >= 32)
      int charCode = input.getCharPressed();
      while (charCode > 0) {
        if ((charCode >= 32 && charCode <= 126) || charCode >= 160) {
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
      ctx2d.drawPanel(x, y, width, height, bgColor: fillBg, borderColor: borderColor);
    }

    // 2. Calcular padding interior
    int leftPadding = 12;
    if (prefixIcon != null && prefixIcon!.isNotEmpty) {
      leftPadding = 34;
      ctx2d.drawText(
        prefixIcon!,
        x + 10,
        y + (height ~/ 4),
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

    final textY = y + (height ~/ 4);
    final textAreaWidth = width - leftPadding - rightPadding;

    if (textAreaWidth > 0) {
      ctx2d.beginScissor(x + leftPadding, y, textAreaWidth, height);

      final safeCursor = _cursorIndex.clamp(0, displayText.length);
      final textBeforeCursor = displayText.substring(0, safeCursor);
      final cursorXOffset = (textBeforeCursor.length * (fontSize * 0.55))
          .toInt();

      int scrollOffsetX = 0;
      if (cursorXOffset > textAreaWidth - 14) {
        scrollOffsetX = cursorXOffset - (textAreaWidth - 14);
      }

      final renderTextX = x + leftPadding - scrollOffsetX;

      // 3. Renderizar Texto / Placeholder y Cursor Parpadeante dentro de los límites
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

      ctx2d.endScissor();
    }

    // 4. Renderizar ícono de acción derecho (Botón Limpiar 'X' o Alternar Contraseña Eye)
    final rightIconX = x + width - rightPadding + 4;
    if (clearable && rawText.isNotEmpty) {
      ctx2d.drawText(
        Icons.close.glyph,
        rightIconX,
        y + (height ~/ 4),
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
        y + (height ~/ 4),
        16,
        const ColorRGBA(160, 175, 195),
      );
    } else if (suffixIcon != null && suffixIcon!.isNotEmpty) {
      ctx2d.drawText(
        suffixIcon!,
        rightIconX,
        y + (height ~/ 4),
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
      'isPasswordVisible': _isPasswordVisible,
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
    if (state.containsKey('isPasswordVisible')) {
      _isPasswordVisible = state['isPasswordVisible'] as bool;
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
