import 'dart:ffi' as ffi;

typedef InputFloatC = ffi.Float Function();
typedef InputFloat = double Function();

typedef InputDoubleC = ffi.Double Function();
typedef InputDouble = double Function();

typedef InputIntBoolC = ffi.Int32 Function(ffi.Int32 buttonOrKey);
typedef InputIntBool = int Function(int buttonOrKey);

typedef InputIntCharC = ffi.Int32 Function();
typedef InputIntChar = int Function();
