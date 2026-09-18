import 'dart:ffi' as ffi;
import 'dart:io' show Directory, File, Platform;
import 'package:path/path.dart' as path;

class NativeLibrary {
  static ffi.DynamicLibrary? _cachedLibrary;

  static ffi.DynamicLibrary get instance {
    if (_cachedLibrary != null) return _cachedLibrary!;

    final currentDir = Directory.current.path;
    final libName = Platform.isWindows ? 'backend.dll' : 'libbackend.so';
    final candidatePaths = <String>[];

    // 1. Revisar variables de entorno CORTEX_HOME y CORTEX_SDK
    final envHome = Platform.environment['CORTEX_HOME'];
    if (envHome != null && envHome.trim().isNotEmpty) {
      final envDir = envHome.trim();
      candidatePaths.add(path.join(envDir, libName));
      candidatePaths.add(path.join(envDir, '..', libName));
      candidatePaths.add(path.join(envDir, '..', 'lib', libName));
      candidatePaths.add(path.join(envDir, '..', 'assets', 'native', libName));
    }

    final envSdk = Platform.environment['CORTEX_SDK'];
    if (envSdk != null && envSdk.trim().isNotEmpty) {
      final sdkDir = envSdk.trim();
      candidatePaths.add(path.join(sdkDir, 'assets', 'native', libName));
      candidatePaths.add(path.join(sdkDir, 'lib', libName));
      candidatePaths.add(path.join(sdkDir, libName));
    }

    // 2. Ruta por defecto del usuario (~/Desarrollo/cortex/sdk)
    final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
    if (homeDir.isNotEmpty) {
      final defaultSdk = path.join(homeDir, 'Desarrollo', 'cortex', 'sdk');
      candidatePaths.add(path.join(defaultSdk, 'assets', 'native', libName));
      candidatePaths.add(path.join(defaultSdk, 'lib', libName));
      candidatePaths.add(path.join(defaultSdk, libName));
    }

    // 3. Rutas relativas del proyecto actual / script ejecutable
    try {
      final scriptDir = path.dirname(Platform.script.toFilePath());
      candidatePaths.addAll([
        path.join(currentDir, 'assets', 'native', libName),
        path.join(scriptDir, 'assets', 'native', libName),
        path.join(scriptDir, '..', 'assets', 'native', libName),
        path.join(scriptDir, '..', 'lib', libName),
        path.join(scriptDir, '..', libName),
        path.join(currentDir, 'lib', libName),
        path.join(currentDir, libName),
        path.join(currentDir, '../backend/target/release', libName),
        path.join(currentDir, '../backend/target/debug', libName),
      ]);
    } catch (_) {}

    for (final candidate in candidatePaths) {
      final normalized = path.normalize(candidate);
      if (File(normalized).existsSync()) {
        try {
          _cachedLibrary = ffi.DynamicLibrary.open(normalized);
          return _cachedLibrary!;
        } catch (_) {}
      }
    }

    // 4. Intentar abrir por nombre de sistema si está cargado o registrado en PATH
    try {
      _cachedLibrary = ffi.DynamicLibrary.open(libName);
      return _cachedLibrary!;
    } catch (_) {}

    throw StateError(
      '❌ ERROR DEL MOTOR CORTEX: No se pudo cargar la librería nativa "$libName".\n'
      'Se buscaron las siguientes rutas candidatos sin éxito:\n'
      '${candidatePaths.map((p) => " - $p").join("\n")}\n'
      'Asegúrate de tener CORTEX_HOME o CORTEX_SDK configurado correctamente.'
    );
  }
}

ffi.DynamicLibrary loadNativeLibrary() => NativeLibrary.instance;
