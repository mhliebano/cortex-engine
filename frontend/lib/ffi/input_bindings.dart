import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

typedef InputFloatC = ffi.Float Function();
typedef InputFloat = double Function();

typedef InputDoubleC = ffi.Double Function();
typedef InputDouble = double Function();

typedef InputIntBoolC = ffi.Int32 Function(ffi.Int32 buttonOrKey);
typedef InputIntBool = int Function(int buttonOrKey);

typedef InputIntCharC = ffi.Int32 Function();
typedef InputIntChar = int Function();

typedef InputSetClipboardC = ffi.Void Function(ffi.Pointer<Utf8> text);
typedef InputSetClipboardDart = void Function(ffi.Pointer<Utf8> text);

typedef InputGetClipboardC = ffi.Pointer<Utf8> Function();
typedef InputGetClipboardDart = ffi.Pointer<Utf8> Function();
