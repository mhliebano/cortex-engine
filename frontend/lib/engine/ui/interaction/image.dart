import 'dart:io';
import 'dart:math' as math;
import 'package:cortex/engine/context2d.dart';
import 'package:cortex/engine/context3d.dart';
import 'package:cortex/engine/input.dart';
import 'package:cortex/engine/ui/element.dart';
import 'package:cortex/engine/ui/icons.dart';
import 'package:cortex/engine/ui/style.dart';

/// Modalidad de ajuste de imagen (`BoxFit`).
enum BoxFit {
  contain,
  cover,
  fill,
}

/// Componente de Renderización de Imagen (`ImageElement` / `Image`).
///
/// Soporta:
/// - Carga local mediante ruta de archivo (`src`).
/// - Carga remota por HTTP/HTTPS automáticamente (`src: 'https://...'` o `Image.network(...)`).
/// - Reutilización de texturas por ID nativo (`textureId`).
/// - Modos de ajuste (`fill`, `contain`, `cover`).
/// - Bordes redondeados integrados (`borderRadius`).
/// - Spinner animado de carga (Loading) mientras descarga de la red.
class ImageElement extends Element {
  final String? src;
  int? textureId;
  final BoxFit fit;
  final double borderRadius;
  late ColorRGBA tint;
  final String? placeholderLabel;

  static final Map<String, String> _networkCache = {};
  static final Set<String> _pendingDownloads = {};

  bool _attemptedLoad = false;
  bool _loadFailed = false;
  String? _resolvedLocalPath;
  int _imgWidth = 0;
  int _imgHeight = 0;

  double _animAngle = 0.0;
  double _animTime = 0.0;

  ImageElement({
    String? className,
    this.src,
    this.textureId,
    this.fit = BoxFit.cover,
    this.borderRadius = 0.0,
    this.placeholderLabel,
    int width = 0,
    int height = 0,
    bool fillWidth = false,
    bool fillHeight = false,
    super.expand,
    super.marginRight,
    super.marginBottom,
  }) : super(fillWidth: fillWidth, fillHeight: fillHeight) {
    final style = className != null ? Style.merge(className) : null;
    this.width = width != 0 ? width : (style?.width ?? 120);
    this.height = height != 0 ? height : (style?.height ?? 120);
    this.tint = style?.textColor ?? ColorRGBA.white;

    if (src != null && (src!.startsWith('http://') || src!.startsWith('https://'))) {
      _initNetworkDownload(src!);
    } else {
      _resolvedLocalPath = src;
    }
  }

  /// Constructor nombrado intuitivo estilo Flutter `Image.network(url)`
  factory ImageElement.network(
    String url, {
    String? className,
    BoxFit fit = BoxFit.cover,
    double borderRadius = 0.0,
    String? placeholderLabel,
    int width = 0,
    int height = 0,
    bool fillWidth = false,
    bool fillHeight = false,
    Expand? expand,
  }) {
    return ImageElement(
      className: className,
      src: url,
      fit: fit,
      borderRadius: borderRadius,
      placeholderLabel: placeholderLabel,
      width: width,
      height: height,
      fillWidth: fillWidth,
      fillHeight: fillHeight,
      expand: expand,
    );
  }

  void _initNetworkDownload(String url) async {
    if (_networkCache.containsKey(url)) {
      _resolvedLocalPath = _networkCache[url];
      return;
    }
    if (_pendingDownloads.contains(url)) return;
    _pendingDownloads.add(url);

    try {
      final uri = Uri.parse(url);
      final ext = uri.pathSegments.isNotEmpty && uri.pathSegments.last.contains('.')
          ? uri.pathSegments.last.split('.').last
          : 'png';
      final fileName = 'cortex_net_${url.hashCode}.$ext';
      final cacheDir = Directory('${Directory.systemTemp.path}/cortex_cache');
      if (!cacheDir.existsSync()) {
        cacheDir.createSync(recursive: true);
      }

      final file = File('${cacheDir.path}/$fileName');
      if (file.existsSync() && file.lengthSync() > 0) {
        _networkCache[url] = file.path;
        _resolvedLocalPath = file.path;
        return;
      }

      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final bytes = await response.fold<List<int>>([], (p, e) => p..addAll(e));
        await file.writeAsBytes(bytes);
        _networkCache[url] = file.path;
        _resolvedLocalPath = file.path;
      } else {
        _loadFailed = true;
      }
    } catch (_) {
      _loadFailed = true;
    } finally {
      _pendingDownloads.remove(url);
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;
    _animTime += dt * 1.5;
    _animAngle = (_animTime * 360.0) % 360.0;
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible || width <= 0 || height <= 0) return;

    // 1. Carga diferida de la textura al resolver la ruta local
    if (!_attemptedLoad && _resolvedLocalPath != null && textureId == null) {
      _attemptedLoad = true;
      final loadedId = ctx2d.loadImage(_resolvedLocalPath!);
      if (loadedId > 0) {
        textureId = loadedId;
        _imgWidth = ctx2d.getImageWidth(loadedId);
        _imgHeight = ctx2d.getImageHeight(loadedId);
      } else {
        _loadFailed = true;
      }
    }

    final hasTexture = textureId != null && textureId! > 0 && !_loadFailed;

    // 2. Si no hay textura o la descarga está en proceso/falló, renderizar marcador con spinner animado
    if (!hasTexture) {
      final bg = const ColorRGBA(28, 34, 46);
      final border = const ColorRGBA(50, 60, 78);
      if (borderRadius > 0) {
        ctx2d.drawRoundRect(x, y, width, height, borderRadius, color: bg);
        ctx2d.drawRoundRectLines(x, y, width, height, borderRadius, color: border);
      } else {
        ctx2d.drawPanel(x, y, width, height, bgColor: bg, borderColor: border);
      }

      final centerX = x + (width ~/ 2);
      final centerY = y + (height ~/ 2);

      if (!_loadFailed) {
        // Spinner animado de carga en anillo azul
        final spinnerRadius = (math.min(width, height) * 0.22).clamp(8.0, 26.0);
        ctx2d.drawCircleLines(centerX, centerY, spinnerRadius, const ColorRGBA(55, 68, 88));

        final startAngle = _animAngle;
        final endAngle = startAngle + 110.0;
        ctx2d.drawArcLines(
          centerX,
          centerY,
          spinnerRadius,
          startAngle,
          endAngle,
          segments: 32,
          color: ColorRGBA.accentBlue,
        );
      } else {
        // Marcador visual de fallo de descarga/archivo
        final iconX = centerX - 10;
        final iconY = centerY - (placeholderLabel != null ? 14 : 10);
        ctx2d.drawText(Icons.broken_image.glyph, iconX, iconY, 20, const ColorRGBA(180, 70, 70));

        if (placeholderLabel != null) {
          final lblW = placeholderLabel!.length * 6;
          final lblX = centerX - (lblW ~/ 2);
          ctx2d.drawText(placeholderLabel!, lblX, iconY + 22, 11, const ColorRGBA(140, 155, 175));
        }
      }
      return;
    }

    // 3. Renderizar textura con recorte scissor si tiene bordes o límites
    final useClip = borderRadius > 0;
    if (useClip) {
      ctx2d.beginScissor(x, y, width, height);
    }

    if (fit == BoxFit.fill || _imgWidth <= 0 || _imgHeight <= 0) {
      ctx2d.drawImage(textureId!, x, y, width: width, height: height, tint: tint);
    } else {
      // Ajuste proporcional (contain / cover)
      final aspectImg = _imgWidth / _imgHeight;
      final aspectBox = width / height;

      int drawW = width;
      int drawH = height;
      int drawX = x;
      int drawY = y;

      if (fit == BoxFit.contain) {
        if (aspectImg > aspectBox) {
          drawW = width;
          drawH = (width / aspectImg).toInt();
          drawY = y + ((height - drawH) ~/ 2);
        } else {
          drawH = height;
          drawW = (height * aspectImg).toInt();
          drawX = x + ((width - drawW) ~/ 2);
        }
      } else if (fit == BoxFit.cover) {
        if (aspectImg > aspectBox) {
          drawH = height;
          drawW = (height * aspectImg).toInt();
          drawX = x - ((drawW - width) ~/ 2);
        } else {
          drawW = width;
          drawH = (width / aspectImg).toInt();
          drawY = y - ((drawH - height) ~/ 2);
        }
      }

      ctx2d.drawImage(textureId!, drawX, drawY, width: drawW, height: drawH, tint: tint);
    }

    if (useClip) {
      ctx2d.endScissor();
    }
  }
}

/// Alias typedef para sintaxis limpia `Image(src: 'path')`
typedef Image = ImageElement;
