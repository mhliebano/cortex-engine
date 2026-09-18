import 'dart:ffi' as ffi;

typedef RendererBeginFrameC =
    ffi.Void Function(ffi.Uint8 r, ffi.Uint8 g, ffi.Uint8 b, ffi.Uint8 a);
typedef RendererBeginFrame = void Function(int r, int g, int b, int a);

typedef RendererVoidActionC = ffi.Void Function();
typedef RendererVoidAction = void Function();
typedef RendererBeginScissorC =
    ffi.Void Function(
      ffi.Int32 x,
      ffi.Int32 y,
      ffi.Int32 width,
      ffi.Int32 height,
    );
typedef RendererBeginScissor =
    void Function(int x, int y, int width, int height);
