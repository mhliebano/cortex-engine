import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

typedef G2dLoadFontC =
    ffi.Int32 Function(ffi.Pointer<Utf8> filePath, ffi.Int32 fontSize);
typedef G2dLoadFont = int Function(ffi.Pointer<Utf8> filePath, int fontSize);

typedef G2dLoadIconFontC =
    ffi.Int32 Function(ffi.Pointer<Utf8> filePath, ffi.Int32 fontSize);
typedef G2dLoadIconFont =
    int Function(ffi.Pointer<Utf8> filePath, int fontSize);

typedef G2dDrawRectC =
    ffi.Void Function(
      ffi.Int32 x,
      ffi.Int32 y,
      ffi.Int32 w,
      ffi.Int32 h,
      ffi.Uint8 r,
      ffi.Uint8 g,
      ffi.Uint8 b,
      ffi.Uint8 a,
    );
typedef G2dDrawRect =
    void Function(int x, int y, int w, int h, int r, int g, int b, int a);

typedef G2dDrawTextC =
    ffi.Void Function(
      ffi.Pointer<Utf8> text,
      ffi.Int32 x,
      ffi.Int32 y,
      ffi.Int32 fontSize,
      ffi.Uint8 r,
      ffi.Uint8 g,
      ffi.Uint8 b,
      ffi.Uint8 a,
    );
typedef G2dDrawText =
    void Function(
      ffi.Pointer<Utf8> text,
      int x,
      int y,
      int fontSize,
      int r,
      int g,
      int b,
      int a,
    );

// Circle
typedef G2dDrawCircleC =
    ffi.Void Function(
      ffi.Int32 centerX,
      ffi.Int32 centerY,
      ffi.Float radius,
      ffi.Uint8 r,
      ffi.Uint8 g,
      ffi.Uint8 b,
      ffi.Uint8 a,
    );
typedef G2dDrawCircle =
    void Function(
      int centerX,
      int centerY,
      double radius,
      int r,
      int g,
      int b,
      int a,
    );

// Circle Lines
typedef G2dDrawCircleLinesC =
    ffi.Void Function(
      ffi.Int32 centerX,
      ffi.Int32 centerY,
      ffi.Float radius,
      ffi.Uint8 r,
      ffi.Uint8 g,
      ffi.Uint8 b,
      ffi.Uint8 a,
    );
typedef G2dDrawCircleLines =
    void Function(
      int centerX,
      int centerY,
      double radius,
      int r,
      int g,
      int b,
      int a,
    );

// Arc (Circle Sector)
typedef G2dDrawArcC =
    ffi.Void Function(
      ffi.Int32 centerX,
      ffi.Int32 centerY,
      ffi.Float radius,
      ffi.Float startAngle,
      ffi.Float endAngle,
      ffi.Int32 segments,
      ffi.Uint8 r,
      ffi.Uint8 g,
      ffi.Uint8 b,
      ffi.Uint8 a,
    );
typedef G2dDrawArc =
    void Function(
      int centerX,
      int centerY,
      double radius,
      double startAngle,
      double endAngle,
      int segments,
      int r,
      int g,
      int b,
      int a,
    );

// Arc Lines (Circle Sector Lines)
typedef G2dDrawArcLinesC =
    ffi.Void Function(
      ffi.Int32 centerX,
      ffi.Int32 centerY,
      ffi.Float radius,
      ffi.Float startAngle,
      ffi.Float endAngle,
      ffi.Int32 segments,
      ffi.Uint8 r,
      ffi.Uint8 g,
      ffi.Uint8 b,
      ffi.Uint8 a,
    );
typedef G2dDrawArcLines =
    void Function(
      int centerX,
      int centerY,
      double radius,
      double startAngle,
      double endAngle,
      int segments,
      int r,
      int g,
      int b,
      int a,
    );

// Textures
typedef G2dLoadTextureC = ffi.Int32 Function(ffi.Pointer<Utf8> filePath);
typedef G2dLoadTexture = int Function(ffi.Pointer<Utf8> filePath);

typedef G2dDrawTextureC =
    ffi.Void Function(
      ffi.Int32 textureId,
      ffi.Int32 x,
      ffi.Int32 y,
      ffi.Int32 width,
      ffi.Int32 height,
      ffi.Float rotation,
      ffi.Uint8 r,
      ffi.Uint8 g,
      ffi.Uint8 b,
      ffi.Uint8 a,
    );
typedef G2dDrawTexture =
    void Function(
      int textureId,
      int x,
      int y,
      int width,
      int height,
      double rotation,
      int r,
      int g,
      int b,
      int a,
    );

typedef G2dGetTextureWidthC = ffi.Int32 Function(ffi.Int32 textureId);
typedef G2dGetTextureWidth = int Function(int textureId);

typedef G2dGetTextureHeightC = ffi.Int32 Function(ffi.Int32 textureId);
typedef G2dGetTextureHeight = int Function(int textureId);

typedef G2dUnloadTextureC = ffi.Int32 Function(ffi.Int32 textureId);
typedef G2dUnloadTexture = int Function(int textureId);

// Rounded Rectangles
typedef G2dDrawRoundRectC =
    ffi.Void Function(
      ffi.Int32 x,
      ffi.Int32 y,
      ffi.Int32 w,
      ffi.Int32 h,
      ffi.Float roundness,
      ffi.Int32 segments,
      ffi.Uint8 r,
      ffi.Uint8 g,
      ffi.Uint8 b,
      ffi.Uint8 a,
    );
typedef G2dDrawRoundRect =
    void Function(
      int x,
      int y,
      int w,
      int h,
      double roundness,
      int segments,
      int r,
      int g,
      int b,
      int a,
    );

typedef G2dDrawRoundRectLinesC =
    ffi.Void Function(
      ffi.Int32 x,
      ffi.Int32 y,
      ffi.Int32 w,
      ffi.Int32 h,
      ffi.Float roundness,
      ffi.Int32 segments,
      ffi.Float lineThick,
      ffi.Uint8 r,
      ffi.Uint8 g,
      ffi.Uint8 b,
      ffi.Uint8 a,
    );
typedef G2dDrawRoundRectLines =
    void Function(
      int x,
      int y,
      int w,
      int h,
      double roundness,
      int segments,
      double lineThick,
      int r,
      int g,
      int b,
      int a,
    );

// Polygon
typedef G2dDrawPolyC =
    ffi.Void Function(
      ffi.Int32 centerX,
      ffi.Int32 centerY,
      ffi.Int32 sides,
      ffi.Float radius,
      ffi.Float rotation,
      ffi.Uint8 r,
      ffi.Uint8 g,
      ffi.Uint8 b,
      ffi.Uint8 a,
    );
typedef G2dDrawPoly =
    void Function(
      int centerX,
      int centerY,
      int sides,
      double radius,
      double rotation,
      int r,
      int g,
      int b,
      int a,
    );

typedef G2dDrawPolyLinesC =
    ffi.Void Function(
      ffi.Int32 centerX,
      ffi.Int32 centerY,
      ffi.Int32 sides,
      ffi.Float radius,
      ffi.Float rotation,
      ffi.Float lineThick,
      ffi.Uint8 r,
      ffi.Uint8 g,
      ffi.Uint8 b,
      ffi.Uint8 a,
    );
typedef G2dDrawPolyLines =
    void Function(
      int centerX,
      int centerY,
      int sides,
      double radius,
      double rotation,
      double lineThick,
      int r,
      int g,
      int b,
      int a,
    );

// Triangle
typedef G2dDrawTriangleC =
    ffi.Void Function(
      ffi.Int32 x1,
      ffi.Int32 y1,
      ffi.Int32 x2,
      ffi.Int32 y2,
      ffi.Int32 x3,
      ffi.Int32 y3,
      ffi.Uint8 r,
      ffi.Uint8 g,
      ffi.Uint8 b,
      ffi.Uint8 a,
    );
typedef G2dDrawTriangle =
    void Function(
      int x1,
      int y1,
      int x2,
      int y2,
      int x3,
      int y3,
      int r,
      int g,
      int b,
      int a,
    );

typedef G2dDrawTriangleLinesC =
    ffi.Void Function(
      ffi.Int32 x1,
      ffi.Int32 y1,
      ffi.Int32 x2,
      ffi.Int32 y2,
      ffi.Int32 x3,
      ffi.Int32 y3,
      ffi.Uint8 r,
      ffi.Uint8 g,
      ffi.Uint8 b,
      ffi.Uint8 a,
    );
typedef G2dDrawTriangleLines =
    void Function(
      int x1,
      int y1,
      int x2,
      int y2,
      int x3,
      int y3,
      int r,
      int g,
      int b,
      int a,
    );
