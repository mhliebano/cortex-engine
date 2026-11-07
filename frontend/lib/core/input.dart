import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:frontend/ffi/lib_loader.dart';
import 'package:frontend/ffi/input_bindings.dart';

class MouseButtons {
  static const int left = 0;
  static const int right = 1;
  static const int middle = 2;
}

/// Códigos de teclas estándar (Raylib / GLFW).
class Keys {
  static const int enter = 257;
  static const int tab = 258;
  static const int backspace = 259;
  static const int insert = 260;
  static const int delete = 261;
  static const int right = 262;
  static const int left = 263;
  static const int down = 264;
  static const int up = 265;
  static const int pageUp = 266;
  static const int pageDown = 267;
  static const int home = 268;
  static const int end = 269;
  static const int capsLock = 280;
  static const int scrollLock = 281;
  static const int numLock = 282;
  static const int printScreen = 283;
  static const int pause = 284;
  static const int f1 = 290;
  static const int f2 = 291;
  static const int f3 = 292;
  static const int f4 = 293;
  static const int f5 = 294;
  static const int f6 = 295;
  static const int f7 = 296;
  static const int f8 = 297;
  static const int f9 = 298;
  static const int f10 = 299;
  static const int f11 = 300;
  static const int f12 = 301;
  static const int leftShift = 340;
  static const int leftControl = 341;
  static const int leftAlt = 342;
  static const int leftSuper = 343;
  static const int rightShift = 344;
  static const int rightControl = 345;
  static const int rightAlt = 346;
  static const int rightSuper = 347;
  static const int space = 32;
  static const int a = 65;
  static const int b = 66;
  static const int c = 67;
  static const int d = 68;
  static const int e = 69;
  static const int f = 70;
  static const int g = 71;
  static const int h = 72;
  static const int i = 73;
  static const int j = 74;
  static const int k = 75;
  static const int l = 76;
  static const int m = 77;
  static const int n = 78;
  static const int o = 79;
  static const int p = 80;
  static const int q = 81;
  static const int r = 82;
  static const int s = 83;
  static const int t = 84;
  static const int u = 85;
  static const int v = 86;
  static const int w = 87;
  static const int x = 88;
  static const int y = 89;
  static const int z = 90;
}

typedef InputSystem = InputEngine;

class InputEngine {
  late final InputFloat _getMouseX;
  late final InputFloat _getMouseY;
  late final InputIntBool _isMouseButtonPressed;
  late final InputIntBool _isMouseButtonDown;
  late final InputIntBool _isMouseButtonReleased;
  late final InputFloat _getMouseWheelMove;
  late final InputIntBool _isKeyPressed;
  late final InputIntBool _isKeyDown;
  late final InputIntChar _getCharPressed;
  late final InputFloat _getFrameTime;
  late final InputDouble _getTime;
  late final InputSetClipboardDart _setClipboard;
  late final InputGetClipboardDart _getClipboard;

  InputEngine() {
    final dylib = loadNativeLibrary();
    _getMouseX = dylib.lookupFunction<InputFloatC, InputFloat>(
      'input_get_mouse_x',
    );
    _getMouseY = dylib.lookupFunction<InputFloatC, InputFloat>(
      'input_get_mouse_y',
    );
    _isMouseButtonPressed = dylib.lookupFunction<InputIntBoolC, InputIntBool>(
      'input_is_mouse_button_pressed',
    );
    _isMouseButtonDown = dylib.lookupFunction<InputIntBoolC, InputIntBool>(
      'input_is_mouse_button_down',
    );
    _isMouseButtonReleased = dylib.lookupFunction<InputIntBoolC, InputIntBool>(
      'input_is_mouse_button_released',
    );
    _getMouseWheelMove = dylib.lookupFunction<InputFloatC, InputFloat>(
      'input_get_mouse_wheel_move',
    );
    _isKeyPressed = dylib.lookupFunction<InputIntBoolC, InputIntBool>(
      'input_is_key_pressed',
    );
    _isKeyDown = dylib.lookupFunction<InputIntBoolC, InputIntBool>(
      'input_is_key_down',
    );
    _getCharPressed = dylib.lookupFunction<InputIntCharC, InputIntChar>(
      'input_get_char_pressed',
    );
    _getFrameTime = dylib.lookupFunction<InputFloatC, InputFloat>(
      'input_get_frame_time',
    );
    _getTime = dylib.lookupFunction<InputDoubleC, InputDouble>(
      'input_get_time',
    );
    _setClipboard = dylib.lookupFunction<InputSetClipboardC, InputSetClipboardDart>(
      'input_set_clipboard_text',
    );
    _getClipboard = dylib.lookupFunction<InputGetClipboardC, InputGetClipboardDart>(
      'input_get_clipboard_text',
    );
  }

  double get mouseX => _getMouseX();
  double get mouseY => _getMouseY();
  double getMouseX() => mouseX;
  double getMouseY() => mouseY;

  bool isMouseButtonPressed(int button) => _isMouseButtonPressed(button) != 0;
  bool isMouseButtonDown(int button) => _isMouseButtonDown(button) != 0;
  bool isMouseButtonReleased(int button) => _isMouseButtonReleased(button) != 0;

  double get mouseWheelMove => _getMouseWheelMove();
  double getMouseWheelMove() => mouseWheelMove;

  bool isKeyPressed(int key) => _isKeyPressed(key) != 0;
  bool isKeyDown(int key) => _isKeyDown(key) != 0;
  int getCharPressed() => _getCharPressed();

  double getFrameTime() => _getFrameTime();
  double getTime() => _getTime();

  /// Comprueba si alguna tecla Control (o Super/Cmd) está pulsada.
  bool get isControlDown =>
      isKeyDown(Keys.leftControl) ||
      isKeyDown(Keys.rightControl) ||
      isKeyDown(Keys.leftSuper) ||
      isKeyDown(Keys.rightSuper);

  /// Comprueba si alguna tecla Shift está pulsada.
  bool get isShiftDown =>
      isKeyDown(Keys.leftShift) || isKeyDown(Keys.rightShift);

  /// Comprueba si alguna tecla Alt está pulsada.
  bool get isAltDown =>
      isKeyDown(Keys.leftAlt) || isKeyDown(Keys.rightAlt);

  /// Copia texto al portapapeles del sistema operativo.
  void setClipboardText(String text) {
    final ptr = text.toNativeUtf8();
    try {
      _setClipboard(ptr);
    } finally {
      calloc.free(ptr);
    }
  }

  /// Obtiene el texto contenido en el portapapeles del sistema operativo.
  String getClipboardText() {
    final ptr = _getClipboard();
    if (ptr == nullptr || ptr.address == 0) return '';
    return ptr.toDartString();
  }

  bool isHovering(int x, int y, int width, int height) {
    final mx = mouseX;
    final my = mouseY;
    return mx >= x && mx <= x + width && my >= y && my <= y + height;
  }
}

/// Encapsula una instancia de [InputEngine] aplicando una transformación
/// de coordenadas (escala y desfasaje) para vistas de lienzo fijo ([ContainerView]).
class TransformedInputEngine extends InputEngine {
  final InputEngine _delegate;
  final double offsetX;
  final double offsetY;
  final double scale;

  TransformedInputEngine(
    this._delegate, {
    required this.offsetX,
    required this.offsetY,
    required this.scale,
  });

  @override
  double get mouseX =>
      scale > 0 ? (_delegate.mouseX - offsetX) / scale : _delegate.mouseX;

  @override
  double get mouseY =>
      scale > 0 ? (_delegate.mouseY - offsetY) / scale : _delegate.mouseY;

  @override
  bool isMouseButtonPressed(int button) => _delegate.isMouseButtonPressed(button);

  @override
  bool isMouseButtonDown(int button) => _delegate.isMouseButtonDown(button);

  @override
  bool isMouseButtonReleased(int button) =>
      _delegate.isMouseButtonReleased(button);

  @override
  double get mouseWheelMove => _delegate.mouseWheelMove;

  @override
  bool isKeyPressed(int key) => _delegate.isKeyPressed(key);

  @override
  bool isKeyDown(int key) => _delegate.isKeyDown(key);

  @override
  int getCharPressed() => _delegate.getCharPressed();

  @override
  double getFrameTime() => _delegate.getFrameTime();

  @override
  double getTime() => _delegate.getTime();

  @override
  bool get isControlDown => _delegate.isControlDown;

  @override
  bool get isShiftDown => _delegate.isShiftDown;

  @override
  bool get isAltDown => _delegate.isAltDown;

  @override
  void setClipboardText(String text) => _delegate.setClipboardText(text);

  @override
  String getClipboardText() => _delegate.getClipboardText();

  @override
  bool isHovering(int x, int y, int width, int height) {
    final mx = mouseX;
    final my = mouseY;
    return mx >= x && mx <= x + width && my >= y && my <= y + height;
  }
}
