import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:cortex/ffi/lib_loader.dart';
import 'ffi/window_bindings.dart';

class WindowFlags {
  static const int vsyncHint = 64;
  static const int fullscreenMode = 2;
  static const int windowResizable = 4;
  static const int windowUndecorated = 8;
  static const int windowHidden = 128;
  static const int windowMinimized = 512;
  static const int windowMaximized = 1024;
  static const int windowUnfocused = 2048;
  static const int windowTopmost = 4096;
  static const int windowAlwaysRun = 256;
  static const int windowTransparent = 16;
  static const int windowHighdpi = 8192;
  static const int windowMousePassthrough = 16384;
  static const int windowSkipTaskbar = 1048576;
}

class WindowManager {
  late final WindowSetConfigFlags _setConfigFlags;
  late final WindowInit _init;
  late final WindowShouldClose _shouldClose;
  late final WindowClose _close;
  late final WindowToggleFullscreen _toggleFullscreen;
  late final WindowMaximize _maximize;
  late final WindowMinimize _minimize;
  late final WindowRestore _restore;
  late final WindowSetState _setState;
  late final WindowClearState _clearState;
  late final WindowIsResized _isResized;
  late final WindowIsFocused _isFocused;
  late final WindowIsMinimized _isMinimized;
  late final WindowGetWidth _getWidth;
  late final WindowGetHeight _getHeight;
  late final WindowSetPosition _setPosition;
  late final WindowSetMinSize _setMinSize;
  late final WindowGetPositionX _getPositionX;
  late final WindowGetPositionY _getPositionY;

  WindowManager() {
    final dylib = loadNativeLibrary();

    _setConfigFlags = dylib
        .lookupFunction<WindowSetConfigFlagsC, WindowSetConfigFlags>(
          'window_set_config_flags',
        );
    _init = dylib.lookupFunction<WindowInitC, WindowInit>('window_init');
    _shouldClose = dylib.lookupFunction<WindowShouldCloseC, WindowShouldClose>(
      'window_should_close',
    );
    _close = dylib.lookupFunction<WindowCloseC, WindowClose>('window_close');
    _toggleFullscreen = dylib
        .lookupFunction<WindowToggleFullscreenC, WindowToggleFullscreen>(
          'window_toggle_fullscreen',
        );
    _maximize = dylib.lookupFunction<WindowMaximizeC, WindowMaximize>(
      'window_maximize',
    );
    _minimize = dylib.lookupFunction<WindowMinimizeC, WindowMinimize>(
      'window_minimize',
    );
    _restore = dylib.lookupFunction<WindowRestoreC, WindowRestore>(
      'window_restore',
    );
    _setState = dylib.lookupFunction<WindowSetStateC, WindowSetState>(
      'window_set_state',
    );
    _clearState = dylib.lookupFunction<WindowClearStateC, WindowClearState>(
      'window_clear_state',
    );
    _isResized = dylib.lookupFunction<WindowIsResizedC, WindowIsResized>(
      'window_is_resized',
    );
    _isFocused = dylib.lookupFunction<WindowIsFocusedC, WindowIsFocused>(
      'window_is_focused',
    );
    _isMinimized = dylib.lookupFunction<WindowIsMinimizedC, WindowIsMinimized>(
      'window_is_minimized',
    );
    _getWidth = dylib.lookupFunction<WindowGetWidthC, WindowGetWidth>(
      'window_get_width',
    );
    _getHeight = dylib.lookupFunction<WindowGetHeightC, WindowGetHeight>(
      'window_get_height',
    );
    _setPosition = dylib.lookupFunction<WindowSetPositionC, WindowSetPosition>(
      'window_set_position',
    );
    _setMinSize = dylib.lookupFunction<WindowSetMinSizeC, WindowSetMinSize>(
      'window_set_min_size',
    );
    _getPositionX = dylib.lookupFunction<WindowGetPositionXC, WindowGetPositionX>(
      'window_get_position_x',
    );
    _getPositionY = dylib.lookupFunction<WindowGetPositionYC, WindowGetPositionY>(
      'window_get_position_y',
    );
  }

  void setConfigFlags(int flags) => _setConfigFlags(flags);

  void init(int w, int h, String title) {
    final t = title.toNativeUtf8();
    _init(w, h, t);
    calloc.free(t);
  }

  bool get shouldClose => _shouldClose() != 0;
  void close() => _close();

  void toggleFullscreen() => _toggleFullscreen();
  void maximize() => _maximize();
  void minimize() => _minimize();
  void restore() => _restore();

  void setState(int flags) => _setState(flags);
  void clearState(int flags) => _clearState(flags);

  bool get isResized => _isResized() != 0;
  bool get isFocused => _isFocused() != 0;
  bool get isMinimized => _isMinimized() != 0;

  int get width => _getWidth();
  int get height => _getHeight();
  int get positionX => _getPositionX();
  int get positionY => _getPositionY();
  void setPosition(int x, int y) => _setPosition(x, y);
  void setMinSize(int w, int h) => _setMinSize(w, h);
}
