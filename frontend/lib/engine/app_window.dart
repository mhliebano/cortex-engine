import 'package:cortex/window.dart';
import 'package:cortex/renderer.dart';
import 'package:cortex/engine/input.dart';

class AppWindow {
  final WindowManager _windowManager = WindowManager();
  final Renderer _renderer = Renderer();
  final InputEngine input = InputEngine();

  void init(int width, int height, String title, {int flags = WindowFlags.windowResizable | WindowFlags.vsyncHint}) {
    _windowManager.setConfigFlags(flags);
    _windowManager.init(width, height, title);
  }

  bool get shouldClose => _windowManager.shouldClose;

  int get width => _windowManager.width;
  int get height => _windowManager.height;
  int get positionX => _windowManager.positionX;
  int get positionY => _windowManager.positionY;

  void setPosition(int x, int y) => _windowManager.setPosition(x, y);

  bool get isResized => _windowManager.isResized;

  double get deltaTime => input.getFrameTime();

  void beginFrame([int r = 30, int g = 30, int b = 35, int a = 255]) {
    _renderer.beginFrame(r, g, b, a);
  }

  void endFrame() {
    _renderer.endFrame();
  }

  void close() {
    _windowManager.close();
  }
}
