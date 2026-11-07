import 'dart:io';

String joinPath(String part1, [String? part2, String? part3, String? part4]) {
  final sep = Platform.pathSeparator;
  var result = part1;
  for (final part in [part2, part3, part4]) {
    if (part != null && part.isNotEmpty) {
      if (result.endsWith(sep)) {
        result += part.startsWith(sep) ? part.substring(1) : part;
      } else {
        result += part.startsWith(sep) ? part : '$sep$part';
      }
    }
  }
  return result;
}

String getBasename(String path) {
  final sep = Platform.pathSeparator;
  final clean = path.endsWith(sep) ? path.substring(0, path.length - 1) : path;
  final idx = clean.lastIndexOf(sep);
  return idx == -1 ? clean : clean.substring(idx + 1);
}

void main(List<String> args) async {
  final String version = args.isNotEmpty ? args.first : '1.0.1';
  final bool embedDart = args.contains('--embed-dart') || true;
  final rootDir = Directory.current;
  final frontendDir = Directory(joinPath(rootDir.path, 'frontend'));
  final backendDir = Directory(joinPath(rootDir.path, 'backend'));
  final releaseSdkDir = Directory(joinPath(rootDir.path, 'release', 'sdk'));

  if (!frontendDir.existsSync()) {
    print('❌ Error: No se encontró la carpeta frontend en ${rootDir.path}');
    exit(1);
  }

  print('======================================================');
  print('🔨 Cortex Engine — Generador de SDK Oficial (v$version)');
  print('======================================================\n');

  // 1. Compilar Backend de Rust en modo Release
  print('⚙️  1/7 Compilando backend nativo en modo Release con Cargo...');
  final cargoRes = Process.runSync('cargo', [
    'build',
    '--release',
    '--manifest-path',
    joinPath(backendDir.path, 'Cargo.toml'),
  ]);

  if (cargoRes.exitCode != 0) {
    print('❌ Error al compilar backend de Rust:');
    print(cargoRes.stderr);
    exit(1);
  }
  print(' [✓] Backend compilado con éxito.\n');

  // 2. Limpiar y preparar estructura de carpetas en release/sdk
  print('🧹 2/7 Preparando directorio limpio release/sdk...');
  if (releaseSdkDir.existsSync()) {
    releaseSdkDir.deleteSync(recursive: true);
  }
  releaseSdkDir.createSync(recursive: true);

  // 3. Copiar framework Dart (lib/)
  print('📦 3/7 Copiando framework Dart (frontend/lib -> release/sdk/lib)...');
  _copyDirectory(
    Directory(joinPath(frontendDir.path, 'lib')),
    Directory(joinPath(releaseSdkDir.path, 'lib')),
    ignoreFilter: (filePath) => filePath.endsWith('libbackend.so') || filePath.endsWith('backend.dll'),
    transformDartImports: true,
  );

  // Crear barrel exports canónicos
  final barrelContent = '''/// Cortex Engine SDK Barrel File
library;

export 'dart:math';

// Core Framework Engine
export 'core/application.dart';
export 'core/app_window.dart';
export 'core/audio.dart';
export 'core/navigator.dart';
export 'core/context2d.dart';
export 'core/context3d.dart';
export 'core/input.dart';
export 'core/scene3d.dart';
export 'core/ui/ui.dart';

// Native Wrappers
export 'wrappers/audio.dart';
export 'wrappers/window.dart';
export 'wrappers/renderer.dart';
export 'wrappers/graphics2d.dart';
export 'wrappers/graphics3d.dart';
''';

  File(joinPath(releaseSdkDir.path, 'lib', 'cortex.dart')).writeAsStringSync(barrelContent);
  File(joinPath(releaseSdkDir.path, 'lib', 'cortex_engine.dart')).writeAsStringSync(barrelContent);
  print(' [✓] Framework Dart copiado y puntos de entrada generados.\n');

  // 4. Copiar binarios nativos del motor (assets/native/)
  print('⚙️  4/7 Copiando binarios nativos a release/sdk/assets/native/...');
  final nativeDir = Directory(joinPath(releaseSdkDir.path, 'assets', 'native'))..createSync(recursive: true);
  final libNames = ['libbackend.so', 'backend.dll'];
  final targetReleaseDir = Directory(joinPath(backendDir.path, 'target', 'release'));

  for (final name in libNames) {
    final candidate = File(joinPath(targetReleaseDir.path, name));
    if (candidate.existsSync()) {
      candidate.copySync(joinPath(nativeDir.path, name));
      final sizeMb = (candidate.lengthSync() / (1024 * 1024)).toStringAsFixed(1);
      print(' [✓] Copiado $name ($sizeMb MB)');
    }
  }

  // Copiar assets generales (fuentes, iconos, shaders)
  final frontendAssets = Directory(joinPath(frontendDir.path, 'assets'));
  if (frontendAssets.existsSync()) {
    _copyDirectory(frontendAssets, Directory(joinPath(releaseSdkDir.path, 'assets')));
    print(' [✓] Fuentes y recursos gráficos copiados.');
  }

  // Copiar documentación
  for (final doc in ['README.md', 'LICENSE', 'CHANGELOG.md']) {
    final file = File(joinPath(rootDir.path, doc));
    if (file.existsSync()) {
      file.copySync(joinPath(releaseSdkDir.path, doc));
    }
  }
  if (Directory(joinPath(rootDir.path, 'docs')).existsSync()) {
    _copyDirectory(Directory(joinPath(rootDir.path, 'docs')), Directory(joinPath(releaseSdkDir.path, 'docs')));
  }
  print(' [✓] Documentación incluida.\n');

  // 5. Generar pubspec.yaml del SDK
  print('⚙️  5/7 Generando configuración canónica pubspec.yaml del SDK...');
  File(joinPath(releaseSdkDir.path, 'pubspec.yaml')).writeAsStringSync('''name: cortex
description: Cortex Engine SDK - High-Performance Native Desktop UI Framework
version: $version

environment:
  sdk: ^3.0.0

dependencies:
  ffi: ^2.2.0
  path: ^1.9.0
  args: ^2.4.2
  vector_math: ^2.4.3

dev_dependencies:
  lints: ^6.0.0
''');

  File(joinPath(releaseSdkDir.path, 'analysis_options.yaml')).writeAsStringSync('''analyzer:
  exclude:
    - 'bin/cache/**'
    - 'dart-sdk/**'
    - '.dart_tool/**'
''');
  print(' [✓] Configuración del SDK generada.\n');

  // 6. Compilar CLI bin/cortex nativo
  print('🛠️  6/7 Compilando herramienta CLI nativa release/sdk/bin/cortex...');
  final cliSource = File(joinPath(frontendDir.path, 'bin', 'cortex.dart'));
  final binDir = Directory(joinPath(releaseSdkDir.path, 'bin'))..createSync(recursive: true);
  final cliOutput = joinPath(binDir.path, Platform.isWindows ? 'cortex.exe' : 'cortex');

  final compileCliRes = Process.runSync('dart', [
    'compile',
    'exe',
    '--packages=${joinPath(frontendDir.path, '.dart_tool', 'package_config.json')}',
    cliSource.path,
    '-o',
    cliOutput,
  ]);

  if (compileCliRes.exitCode != 0) {
    print('❌ Error al compilar binario cortex:');
    print(compileCliRes.stderr);
    exit(1);
  }
  if (!Platform.isWindows) {
    Process.runSync('chmod', ['+x', cliOutput]);
  }
  print(' [✓] CLI nativo "cortex" compilado exitosamente.\n');

  // 6b. Embeber Dart SDK (Zero-Setup estilo Flutter)
  if (embedDart) {
    print('🎯 6b/7 Empaquetando Dart SDK para experiencia Zero-Setup (estilo Flutter)...');
    final systemDartSdk = _findSystemDartSdk();
    if (systemDartSdk != null && systemDartSdk.existsSync()) {
      final cacheDartDir = Directory(joinPath(binDir.path, 'cache', 'dart-sdk'))..createSync(recursive: true);
      _copyDirectory(
        systemDartSdk,
        cacheDartDir,
        ignoreFilter: (path) {
          final base = getBasename(path);
          return base.contains('asan') || base.contains('msan') || base.contains('tsan') || base == '.dartServer';
        },
      );
      print(' [✓] Dart SDK embebido en release/sdk/bin/cache/dart-sdk');
    } else {
      print(' [!] Dart SDK no localizado para embeber. El CLI lo descargará automáticamente al primer uso.');
    }
    print('');
  }

  // 7. Generar archivo comprimido de distribución (tar.gz)
  print('📦 7/7 Generando tarball de distribución release/cortex-sdk.tar.gz...');
  final tarFile = joinPath(rootDir.path, 'release', 'cortex-sdk.tar.gz');
  if (File(tarFile).existsSync()) {
    File(tarFile).deleteSync();
  }

  final tarRes = Process.runSync('tar', [
    '-czf',
    tarFile,
    '-C',
    joinPath(rootDir.path, 'release'),
    'sdk',
  ]);

  if (tarRes.exitCode == 0) {
    final sizeMb = (File(tarFile).lengthSync() / (1024 * 1024)).toStringAsFixed(1);
    print(' [✓] Archivo comprimido generado: release/cortex-sdk.tar.gz ($sizeMb MB)');
  } else {
    print(' [!] Advertencia al generar tar.gz: ${tarRes.stderr}');
  }

  print('\n======================================================');
  print('🎉 ¡SDK de Cortex Engine generado con éxito!');
  print('======================================================');
  print('Ruta local del SDK: ${releaseSdkDir.path}');
  print('Archivo comprimido: release/cortex-sdk.tar.gz');
  print('\nInstrucciones para comenzar a producir:');
  print('  1. export CORTEX_HOME="${releaseSdkDir.path}"');
  print('  2. export PATH="\$PATH:\$CORTEX_HOME/bin"');
  print('  3. cortex doctor');
  print('  4. cortex create mi_proyecto');
  print('  5. cd mi_proyecto && cortex run\n');
}

Directory? _findSystemDartSdk() {
  try {
    final exePath = File(Platform.resolvedExecutable).resolveSymbolicLinksSync();
    final parent = Directory(exePath).parent.parent;
    if (File(joinPath(parent.path, 'bin', 'dart')).existsSync() &&
        Directory(joinPath(parent.path, 'lib')).existsSync()) {
      return parent;
    }
    // Flutter cached dart-sdk
    final flutterCache = Directory(joinPath(parent.path, 'cache', 'dart-sdk'));
    if (flutterCache.existsSync() && File(joinPath(flutterCache.path, 'bin', 'dart')).existsSync()) {
      return flutterCache;
    }
  } catch (_) {}
  return null;
}

void _copyDirectory(
  Directory source,
  Directory destination, {
  bool Function(String path)? ignoreFilter,
  bool transformDartImports = false,
}) {
  destination.createSync(recursive: true);
  for (var entity in source.listSync(recursive: false)) {
    if (ignoreFilter != null && ignoreFilter(entity.path)) {
      continue;
    }
    final filename = getBasename(entity.path);
    final targetPath = joinPath(destination.path, filename);
    if (entity is Directory) {
      _copyDirectory(
        entity,
        Directory(targetPath),
        ignoreFilter: ignoreFilter,
        transformDartImports: transformDartImports,
      );
    } else if (entity is File) {
      if (transformDartImports && filename.endsWith('.dart')) {
        final content = entity.readAsStringSync();
        final transformed = content.replaceAll('package:frontend/', 'package:cortex/');
        File(targetPath).writeAsStringSync(transformed);
      } else {
        entity.copySync(targetPath);
      }
    }
  }
}
