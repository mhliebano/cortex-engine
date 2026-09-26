import 'dart:ffi';
import 'package:frontend/ffi/lib_loader.dart';
import 'package:frontend/ffi/input_bindings.dart';

class MouseButtons {
  static const int left = 0;
  static const int right = 1;
  static const int middle = 2;
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
  }

  double get mouseX => _getMouseX();
  double get mouseY => _getMouseY();

  bool isMouseButtonPressed(int button) => _isMouseButtonPressed(button) != 0;
  bool isMouseButtonDown(int button) => _isMouseButtonDown(button) != 0;
  bool isMouseButtonReleased(int button) => _isMouseButtonReleased(button) != 0;

  double get mouseWheelMove => _getMouseWheelMove();

  bool isKeyPressed(int key) => _isKeyPressed(key) != 0;
  bool isKeyDown(int key) => _isKeyDown(key) != 0;
  int getCharPressed() => _getCharPressed();

  double getFrameTime() => _getFrameTime();
  double getTime() => _getTime();

  bool isHovering(int x, int y, int width, int height) {
    final mx = mouseX;
    final my = mouseY;
    return mx >= x && mx <= x + width && my >= y && my <= y + height;
  }
}

/// Encapsula una instancia de [InputEngine] aplicando una transformación
/// de coordenadas (escala y desfasaje) para vistas de lienzo fijo (`CanvasView`).
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
  bool isHovering(int x, int y, int width, int height) {
    final mx = mouseX;
    final my = mouseY;
    return mx >= x && mx <= x + width && my >= y && my <= y + height;
  }
}
