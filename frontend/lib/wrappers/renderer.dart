// lib/renderer.dart
import 'dart:ffi';

import 'package:cortex/ffi/lib_loader.dart';
import '../ffi/renderer_bindings.dart';

class Renderer {
  late final RendererBeginFrame _beginFrame;
  late final RendererVoidAction _endFrame;
  late final RendererBeginScissor _beginScissor;
  late final RendererVoidAction _endScissor;

  Renderer() {
    final dylib = loadNativeLibrary();

    _beginFrame = dylib.lookupFunction<RendererBeginFrameC, RendererBeginFrame>(
      'renderer_begin_frame',
    );
    _endFrame = dylib.lookupFunction<RendererVoidActionC, RendererVoidAction>(
      'renderer_end_frame',
    );
    _beginScissor = dylib
        .lookupFunction<RendererBeginScissorC, RendererBeginScissor>(
          'renderer_begin_scissor',
        );
    _endScissor = dylib.lookupFunction<RendererVoidActionC, RendererVoidAction>(
      'renderer_end_scissor',
    );
  }

  void beginFrame(int r, int g, int b, int a) => _beginFrame(r, g, b, a);
  void endFrame() => _endFrame();
  void beginScissor(int x, int y, int width, int height) =>
      _beginScissor(x, y, width, height);
  void endScissor() => _endScissor();
}
