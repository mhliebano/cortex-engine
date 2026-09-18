import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

// Firmas C (17)
typedef WindowSetConfigFlagsC = ffi.Void Function(ffi.Uint32);
typedef WindowInitC =
    ffi.Void Function(ffi.Int32, ffi.Int32, ffi.Pointer<Utf8>);
typedef WindowShouldCloseC = ffi.Int32 Function();
typedef WindowCloseC = ffi.Void Function();
typedef WindowToggleFullscreenC = ffi.Void Function();
typedef WindowMaximizeC = ffi.Void Function();
typedef WindowMinimizeC = ffi.Void Function();
typedef WindowRestoreC = ffi.Void Function();
typedef WindowSetStateC = ffi.Void Function(ffi.Uint32);
typedef WindowClearStateC = ffi.Void Function(ffi.Uint32);
typedef WindowIsResizedC = ffi.Int32 Function();
typedef WindowIsFocusedC = ffi.Int32 Function();
typedef WindowIsMinimizedC = ffi.Int32 Function();
typedef WindowGetWidthC = ffi.Int32 Function();
typedef WindowGetHeightC = ffi.Int32 Function();
typedef WindowSetPositionC = ffi.Void Function(ffi.Int32, ffi.Int32);
typedef WindowSetMinSizeC = ffi.Void Function(ffi.Int32, ffi.Int32);
typedef WindowGetPositionXC = ffi.Int32 Function();
typedef WindowGetPositionYC = ffi.Int32 Function();

// Firmas Dart (19)
typedef WindowSetConfigFlags = void Function(int);
typedef WindowInit = void Function(int, int, ffi.Pointer<Utf8>);
typedef WindowShouldClose = int Function();
typedef WindowClose = void Function();
typedef WindowToggleFullscreen = void Function();
typedef WindowMaximize = void Function();
typedef WindowMinimize = void Function();
typedef WindowRestore = void Function();
typedef WindowSetState = void Function(int);
typedef WindowClearState = void Function(int);
typedef WindowIsResized = int Function();
typedef WindowIsFocused = int Function();
typedef WindowIsMinimized = int Function();
typedef WindowGetWidth = int Function();
typedef WindowGetHeight = int Function();
typedef WindowSetPosition = void Function(int, int);
typedef WindowSetMinSize = void Function(int, int);
typedef WindowGetPositionX = int Function();
typedef WindowGetPositionY = int Function();
