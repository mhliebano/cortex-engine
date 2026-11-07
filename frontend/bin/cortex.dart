import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

const String cortexVersion = '1.0.1';

void main(List<String> args) async {
  final runner = CommandRunner<void>(
    'cortex',
    'Cortex Engine SDK - Herramienta de línea de comandos para desarrollo de escritorio nativo.',
  )
    ..addCommand(DoctorCommand())
    ..addCommand(CreateCommand())
    ..addCommand(RunCommand())
    ..addCommand(BuildCommand());

  runner.argParser.addFlag(
    'version',
    abbr: 'v',
    negatable: false,
    help: 'Muestra la versión actual del SDK de Cortex.',
  );

  try {
    final results = runner.argParser.parse(args);
    if (results['version'] == true) {
      print('Cortex Engine SDK v$cortexVersion');
      return;
    }
    await runner.run(args);
  } on UsageException catch (e) {
    print(e.message);
    print('\n${e.usage}');
    exit(64);
  } catch (e, stack) {
    print('❌ Error: $e');
    if (Platform.environment['CORTEX_DEBUG'] == 'true') {
      print(stack);
    }
    exit(1);
  }
}

/// Localiza la raíz del SDK de Cortex de forma inteligente.
String findCortexSdkPath() {
  // 1. Variable de entorno explícita CORTEX_HOME o CORTEX_SDK
  final envHome = Platform.environment['CORTEX_HOME'] ?? Platform.environment['CORTEX_SDK'];
  if (envHome != null && envHome.trim().isNotEmpty) {
    final candidate = Directory(envHome.trim());
    if (candidate.existsSync()) {
      return candidate.path;
    }
  }

  // 2. Relativo al ejecutable compilado bin/cortex -> SDK root
  try {
    final exeFile = File(Platform.resolvedExecutable);
    final binDir = exeFile.parent;
    final sdkDir = binDir.parent;
    if (File(p.join(sdkDir.path, 'pubspec.yaml')).existsSync() ||
        Directory(p.join(sdkDir.path, 'lib')).existsSync()) {
      return sdkDir.path;
    }
  } catch (_) {}

  // 3. Relativo al script de ejecución Platform.script
  try {
    final scriptFile = File(Platform.script.toFilePath());
    final binDir = scriptFile.parent;
    final candidate1 = binDir.parent; // frontend o sdk
    if (File(p.join(candidate1.path, 'pubspec.yaml')).existsSync()) {
      return candidate1.path;
    }
    final candidate2 = candidate1.parent; // raíz del repo cortex
    if (Directory(p.join(candidate2.path, 'frontend')).existsSync()) {
      return p.join(candidate2.path, 'frontend');
    }
  } catch (_) {}

  // 4. Ubicación por defecto en ~/.cortex o ~/cortex
  final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
  if (homeDir.isNotEmpty) {
    final candidates = [
      p.join(homeDir, '.cortex'),
      p.join(homeDir, 'cortex'),
      p.join(homeDir, 'Desarrollo', 'cortex', 'release', 'sdk'),
      p.join(homeDir, 'Desarrollo', 'cortex', 'sdk'),
      p.join(homeDir, 'Proyectos', 'hibridos', 'cortex', 'frontend'),
    ];
    for (final c in candidates) {
      if (Directory(c).existsSync()) {
        return c;
      }
    }
  }

  return Directory.current.path;
}

/// Localiza el binario de Dart (interno del SDK o del sistema).
/// Si no existe ninguno, ofrece descargarlo automáticamente al caché del SDK (patrón Flutter).
Future<String> findOrEnsureDartExecutable(String sdkPath, {bool autoDownload = true}) async {
  final exeName = Platform.isWindows ? 'dart.exe' : 'dart';

  // 1. Verificar Dart embebido en bin/cache/dart-sdk/bin/dart (o dart-sdk/bin/dart)
  final cacheDart = p.join(sdkPath, 'bin', 'cache', 'dart-sdk', 'bin', exeName);
  if (File(cacheDart).existsSync()) {
    return cacheDart;
  }
  final rootCacheDart = p.join(sdkPath, 'dart-sdk', 'bin', exeName);
  if (File(rootCacheDart).existsSync()) {
    return rootCacheDart;
  }

  // 2. Verificar Dart en el PATH del sistema
  try {
    final check = Process.runSync('which', ['dart']);
    if (check.exitCode == 0) {
      final path = (check.stdout as String).trim();
      if (path.isNotEmpty && File(path).existsSync()) {
        return path;
      }
    }
  } catch (_) {}

  // Intento directo en Windows o fallback
  try {
    final testRun = Process.runSync('dart', ['--version']);
    if (testRun.exitCode == 0) {
      return 'dart';
    }
  } catch (_) {}

  // 3. Auto-descarga al estilo Flutter en bin/cache/dart-sdk
  if (!autoDownload) {
    throw StateError('Dart SDK no encontrado en el SDK ni en el sistema PATH.');
  }

  return await _downloadDartSdk(sdkPath);
}

/// Descarga el Dart SDK oficial para la plataforma y arquitectura actual.
Future<String> _downloadDartSdk(String sdkPath) async {
  print('⚡ No se detectó Dart SDK instalado.');
  print('📦 Descargando Dart SDK oficial (patrón Zero-Setup estilo Flutter)...');

  String os = 'linux';
  if (Platform.isWindows) os = 'windows';
  if (Platform.isMacOS) os = 'macos';

  String arch = 'x64';
  // Soporte ARM64 en Linux/Mac
  final unameRes = Process.runSync('uname', ['-m']);
  if (unameRes.exitCode == 0) {
    final m = (unameRes.stdout as String).trim().toLowerCase();
    if (m.contains('aarch64') || m.contains('arm64')) {
      arch = 'arm64';
    }
  }

  final url = 'https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-$os-$arch-release.zip';
  final targetDir = Directory(p.join(sdkPath, 'bin', 'cache'))..createSync(recursive: true);
  final zipFile = File(p.join(targetDir.path, 'dart-sdk.zip'));

  print('   Descargando desde: $url');
  final client = HttpClient();
  try {
    final req = await client.getUrl(Uri.parse(url));
    final resp = await req.close();
    if (resp.statusCode != 200) {
      throw StateError('Error HTTP ${resp.statusCode} al descargar Dart SDK.');
    }

    final sink = zipFile.openWrite();
    await resp.pipe(sink);
    await sink.close();
    print('   [✓] Descarga completada.');

    print('   Descomprimiendo en ${targetDir.path}...');
    final unzipRes = Process.runSync('unzip', ['-q', '-o', zipFile.path, '-d', targetDir.path]);
    if (unzipRes.exitCode != 0) {
      throw StateError('Error al descomprimir: ${unzipRes.stderr}');
    }

    try { zipFile.deleteSync(); } catch (_) {}

    final dartExe = p.join(targetDir.path, 'dart-sdk', 'bin', Platform.isWindows ? 'dart.exe' : 'dart');
    if (!Platform.isWindows) {
      Process.runSync('chmod', ['+x', dartExe]);
    }

    print(' [✓] Dart SDK instalado exitosamente en ${p.dirname(p.dirname(dartExe))}');
    return dartExe;
  } finally {
    client.close();
  }
}

/// Comando `cortex doctor`: Diagnóstico de salud del SDK y entorno de desarrollo.
class DoctorCommand extends Command<void> {
  @override
  final String name = 'doctor';
  @override
  final String description = 'Verifica que el entorno, SDK y dependencias nativas estén listos.';

  @override
  Future<void> run() async {
    print('🔍 Ejecutando diagnóstico de Cortex Doctor (v$cortexVersion)...\n');

    final sdkPath = findCortexSdkPath();
    final libName = Platform.isWindows ? 'backend.dll' : 'libbackend.so';

    // 1. Diagnóstico del SDK de Cortex
    final sdkExists = Directory(sdkPath).existsSync();
    final libCortexExists = File(p.join(sdkPath, 'lib', 'cortex.dart')).existsSync() ||
        File(p.join(sdkPath, 'lib', 'cortex_engine.dart')).existsSync();

    if (sdkExists && libCortexExists) {
      print(' [✓] Cortex SDK (v$cortexVersion instalado en $sdkPath)');
    } else {
      print(' [✗] Cortex SDK: No se encontró lib/cortex.dart en "$sdkPath"');
      print('     Configura la variable de entorno CORTEX_HOME apuntando a la raíz del SDK.');
    }

    // 2. Diagnóstico del Motor Nativo (Rust / Raylib)
    final nativeCandidates = [
      p.join(sdkPath, 'assets', 'native', libName),
      p.join(sdkPath, libName),
      p.join(sdkPath, 'lib', libName),
      p.join(sdkPath, '..', 'backend', 'target', 'release', libName),
      p.join(sdkPath, 'backend', 'target', 'release', libName),
    ];
    String? foundNativeLib;
    for (final c in nativeCandidates) {
      if (File(c).existsSync()) {
        foundNativeLib = c;
        break;
      }
    }

    if (foundNativeLib != null) {
      final sizeMb = (File(foundNativeLib).lengthSync() / (1024 * 1024)).toStringAsFixed(1);
      print(' [✓] Motor Gráfico Nativo ($libName detectado: $sizeMb MB en $foundNativeLib)');
    } else {
      print(' [!] Motor Gráfico Nativo: "$libName" no encontrado en las rutas del SDK.');
      print('     Compila el backend con: cargo build --release --manifest-path backend/Cargo.toml');
    }

    // 3. Diagnóstico de Dart SDK (Interno o del Sistema)
    try {
      final dartExe = await findOrEnsureDartExecutable(sdkPath, autoDownload: false);
      final dartRes = Process.runSync(dartExe, ['--version']);
      final dartVersion = (dartRes.stdout.toString() + dartRes.stderr.toString()).trim();
      final isEmbedded = dartExe.contains('cache') || dartExe.contains('dart-sdk');
      print(' [✓] Dart SDK ($dartVersion ${isEmbedded ? '[Autocontenido en Cortex SDK]' : '[Sistema]'})');
    } catch (_) {
      print(' [!] Dart SDK: No encontrado. Cortex lo descargará automáticamente al primer uso (Zero-Setup).');
    }

    // 4. Herramientas de empaquetado del sistema
    if (Platform.isLinux) {
      final tarExists = Process.runSync('which', ['tar']).exitCode == 0;
      final gzipExists = Process.runSync('which', ['gzip']).exitCode == 0;
      if (tarExists && gzipExists) {
        print(' [✓] Herramientas de empaquetado Linux (tar, gzip disponibles)');
      }
    } else if (Platform.isWindows) {
      print(' [✓] Plataforma Windows detectada');
    }

    print('\n• Diagnóstico completado.');
  }
}

/// Comando `cortex create <nombre_proyecto>`: Crea un nuevo proyecto moderno de Cortex.
class CreateCommand extends Command<void> {
  @override
  final String name = 'create';
  @override
  final String description = 'Crea un nuevo proyecto de aplicación nativa con Cortex Engine.';

  CreateCommand() {
    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Directorio de destino para el nuevo proyecto.',
    );
  }

  @override
  Future<void> run() async {
    if (argResults!.rest.isEmpty) {
      print('❌ Error: Debes especificar el nombre de la aplicación.');
      print('Uso: cortex create <nombre_de_la_app>');
      exit(1);
    }

    final projectName = argResults!.rest.first;
    final sanitizedName = projectName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();

    final targetDir = argResults!['output'] != null
        ? Directory(argResults!['output'] as String)
        : Directory(p.join(Directory.current.path, projectName));

    if (targetDir.existsSync() && targetDir.listSync().isNotEmpty) {
      print('❌ Error: El directorio "${targetDir.path}" ya existe y no está vacío.');
      exit(1);
    }

    print('🚀 Creando nuevo proyecto Cortex: "$projectName"...');
    targetDir.createSync(recursive: true);

    final sdkPath = findCortexSdkPath();

    // 1. Generar pubspec.yaml estándar de Dart
    final pubspecContent = '''name: $sanitizedName
description: Aplicación de escritorio creada con Cortex Engine SDK
version: 1.0.0

environment:
  sdk: ^3.0.0

dependencies:
  cortex:
    path: $sdkPath

dev_dependencies:
  lints: ^6.0.0
''';
    File(p.join(targetDir.path, 'pubspec.yaml')).writeAsStringSync(pubspecContent);

    // 2. Generar analysis_options.yaml
    final analysisOptionsContent = '''include: package:lints/recommended.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
''';
    File(p.join(targetDir.path, 'analysis_options.yaml')).writeAsStringSync(analysisOptionsContent);

    // 3. Generar .gitignore
    final gitignoreContent = '''.dart_tool/
.packages
build/
dist/
pubspec.lock
''';
    File(p.join(targetDir.path, '.gitignore')).writeAsStringSync(gitignoreContent);

    // 4. Generar bin/main.dart con arquitectura moderna (ControlNode / FluidView / Flex)
    final binDir = Directory(p.join(targetDir.path, 'bin'))..createSync(recursive: true);
    final mainDartContent = '''import 'package:cortex/cortex.dart';

void main() async {
  final app = Application(
    title: "${_formatTitle(projectName)}",
    width: 960,
    height: 640,
    flags: WindowFlags.windowResizable,
  );

  app.registerView(HomeView());
  await app.run();
}

class HomeView extends FluidView {
  HomeView()
      : super(
          id: "home_view",
          localStyleRules: {
            "title": StyleRules(fontSize: 26, textColor: ColorRGBA.white),
            "subtitle": StyleRules(fontSize: 14, textColor: ColorRGBA(156, 163, 175, 255)),
            "card": StyleRules(
              bgColor: ColorRGBA(31, 41, 55, 255),
              borderColor: ColorRGBA(55, 65, 81, 255),
              borderRadius: 8,
            ),
          },
          localLayoutRules: {
            "card": LayoutRules(
              padding: EdgeInsets.all(20),
              width: double.infinity,
            ),
          },
        );

  int _counter = 0;

  @override
  List<Panel> build() {
    return [
      Panel(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(32),
        layout: PanelLayout.vertical,
        children: [
          // 1. Encabezado principal
          Row(
            crossAlign: CrossAlign.center,
            children: [
              Col(
                gap: 8,
                children: [
                  Label(
                    text: "${_formatTitle(projectName)}",
                    styleClass: "title",
                  ),
                  Label(
                    text: "Desarrollado con Cortex Engine (Dart + Rust / Raylib OpenGL)",
                    styleClass: "subtitle",
                  ),
                ],
              ),
            ],
          ),
          Spacer(24),

          // 2. Tarjeta interactiva de bienvenida
          Row(
            children: [
              Container(
                styleClass: "card",
                layoutClass: "card",
                child: Col(
                  gap: 16,
                  children: [
                    Label(
                      text: "¡Tu aplicación nativa está lista para producir!",
                      styleClass: "title",
                    ),
                    Label(
                      text: "Controles 100% vectoriales, acelerados por GPU y con 0% de uso de CPU en reposo.",
                      styleClass: "subtitle",
                    ),
                    Row(
                      gap: 12,
                      crossAlign: CrossAlign.center,
                      children: [
                        Button(
                          text: "Pulsar botón (+1)",
                          onClick: () {
                            _counter++;
                            print("Contador: \$_counter");
                          },
                        ),
                        Button(
                          text: "Reiniciar",
                          onClick: () {
                            _counter = 0;
                            print("Contador reiniciado.");
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
''';
    File(p.join(binDir.path, 'main.dart')).writeAsStringSync(mainDartContent);

    // 5. Ejecutar dart pub get
    print('📦 Resolviendo paquetes con "dart pub get"...');
    final dartExe = await findOrEnsureDartExecutable(sdkPath);
    final pubGetRes = Process.runSync(
      dartExe,
      ['pub', 'get'],
      workingDirectory: targetDir.path,
    );

    if (pubGetRes.exitCode == 0) {
      print(' [✓] Dependencias resueltas con éxito.');
    } else {
      print(' [!] Advertencia al ejecutar dart pub get:');
      print(pubGetRes.stderr);
    }

    print('\n✨ ¡Proyecto "$projectName" creado con éxito en ${targetDir.path}!');
    print('\nPara comenzar a trabajar:');
    print('  cd ${p.relative(targetDir.path)}');
    print('  cortex run');
  }

  String _formatTitle(String s) {
    if (s.isEmpty) return 'Cortex App';
    final parts = s.split(RegExp(r'[_ -]'));
    return parts.map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1)).join(' ');
  }
}

/// Comando `cortex run`: Ejecuta la aplicación en desarrollo.
class RunCommand extends Command<void> {
  @override
  final String name = 'run';
  @override
  final String description = 'Ejecuta la aplicación Cortex en modo interactivo.';

  @override
  Future<void> run() async {
    final projectDir = Directory.current;
    final mainFile = File(p.join(projectDir.path, 'bin', 'main.dart'));

    if (!mainFile.existsSync()) {
      print('❌ Error: No se encontró "bin/main.dart" en el directorio actual (${projectDir.path}).');
      print('Asegúrate de estar en la raíz de un proyecto Cortex.');
      exit(1);
    }

    final sdkPath = findCortexSdkPath();
    final env = Map<String, String>.from(Platform.environment);
    env['CORTEX_HOME'] = sdkPath;

    final nativeDir = p.join(sdkPath, 'assets', 'native');
    if (Platform.isLinux) {
      final currentLd = env['LD_LIBRARY_PATH'] ?? '';
      env['LD_LIBRARY_PATH'] = currentLd.isEmpty ? nativeDir : '$nativeDir:$currentLd';
    }

    final dartExe = await findOrEnsureDartExecutable(sdkPath);

    print('⚡ Iniciando aplicación Cortex (${mainFile.path})...\n');
    final process = await Process.start(
      dartExe,
      ['run', 'bin/main.dart', ...argResults!.rest],
      workingDirectory: projectDir.path,
      environment: env,
      mode: ProcessStartMode.inheritStdio,
    );

    exit(await process.exitCode);
  }
}

/// Comando `cortex build`: Compila la aplicación a un paquete de distribución final standalone.
class BuildCommand extends Command<void> {
  @override
  final String name = 'build';
  @override
  final String description = 'Compila y empaqueta la aplicación en un paquete de distribución nativo.';

  BuildCommand() {
    argParser.addFlag(
      'archive',
      abbr: 'a',
      defaultsTo: true,
      help: 'Genera además un archivo comprimido .tar.gz (Linux) o .zip (Windows).',
    );
    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Directorio de salida para la distribución (por defecto dist/).',
    );
  }

  @override
  Future<void> run() async {
    final projectDir = Directory.current;
    final mainFile = File(p.join(projectDir.path, 'bin', 'main.dart'));

    if (!mainFile.existsSync()) {
      print('❌ Error: No se encontró "bin/main.dart".');
      exit(1);
    }

    final sdkPath = findCortexSdkPath();
    final projectName = p.basename(projectDir.path);
    final outputBase = argResults!['output'] != null
        ? Directory(argResults!['output'] as String)
        : Directory(p.join(projectDir.path, 'dist'));

    final appDistDir = Directory(p.join(outputBase.path, projectName));
    if (appDistDir.existsSync()) {
      appDistDir.deleteSync(recursive: true);
    }
    appDistDir.createSync(recursive: true);

    final dartExe = await findOrEnsureDartExecutable(sdkPath);

    print('⚙️  1/4 Compilando ejecutable nativo AOT para "$projectName"...');
    final exeOutput = p.join(appDistDir.path, projectName);
    final compileRes = Process.runSync(dartExe, [
      'compile',
      'exe',
      mainFile.path,
      '-o',
      exeOutput,
    ]);

    if (compileRes.exitCode != 0) {
      print('❌ Error durante la compilación AOT de Dart:');
      print(compileRes.stderr);
      exit(1);
    }
    print(' [✓] Binario compilado: $exeOutput');

    // 2. Copiar librería nativa (libbackend.so / backend.dll)
    print('⚙️  2/4 Empaquetando motor nativo...');
    final libName = Platform.isWindows ? 'backend.dll' : 'libbackend.so';
    final nativeCandidates = [
      p.join(sdkPath, 'assets', 'native', libName),
      p.join(sdkPath, libName),
      p.join(sdkPath, 'lib', libName),
      p.join(sdkPath, '..', 'backend', 'target', 'release', libName),
      p.join(sdkPath, 'backend', 'target', 'release', libName),
    ];

    String? foundLib;
    for (final c in nativeCandidates) {
      if (File(c).existsSync()) {
        foundLib = c;
        break;
      }
    }

    if (foundLib == null) {
      print('❌ Error: No se pudo localizar "$libName" para empaquetar.');
      exit(1);
    }

    final destLib = p.join(appDistDir.path, libName);
    File(foundLib).copySync(destLib);
    print(' [✓] Librería nativa empaquetada: $destLib');

    // 3. Copiar recursos (assets)
    print('⚙️  3/4 Copiando fuentes y recursos...');
    final sdkAssets = Directory(p.join(sdkPath, 'assets'));
    final distAssets = Directory(p.join(appDistDir.path, 'assets'));
    if (sdkAssets.existsSync()) {
      _copyDir(sdkAssets, distAssets);
    }
    final projectAssets = Directory(p.join(projectDir.path, 'assets'));
    if (projectAssets.existsSync()) {
      _copyDir(projectAssets, distAssets);
    }
    print(' [✓] Recursos incluidos en ${distAssets.path}');

    // 4. Generar script lanzador run.sh
    if (Platform.isLinux) {
      final runScript = File(p.join(appDistDir.path, 'run.sh'));
      runScript.writeAsStringSync('''#!/usr/bin/env bash
DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
export LD_LIBRARY_PATH="\$DIR:\$DIR/lib:\$LD_LIBRARY_PATH"
exec "\$DIR/$projectName" "\$@"
''');
      Process.runSync('chmod', ['+x', runScript.path, exeOutput]);
    }

    // 5. Generar archivo comprimido de distribución (.tar.gz)
    if (argResults!['archive'] == true && Platform.isLinux) {
      print('📦 4/4 Generando paquete portátil para distribución...');
      final archiveName = '$projectName-linux-x64.tar.gz';
      final archivePath = p.join(outputBase.path, archiveName);

      final tarRes = Process.runSync('tar', [
        '-czf',
        archivePath,
        '-C',
        outputBase.path,
        projectName,
      ]);

      if (tarRes.exitCode == 0) {
        final archiveSize = (File(archivePath).lengthSync() / (1024 * 1024)).toStringAsFixed(1);
        print(' [✓] Archivo comprimido generado: $archivePath ($archiveSize MB)');
      }
    }

    print('\n🎉 ¡Distribución completada con éxito!');
    print('Directorio final: ${appDistDir.path}');
    print('El usuario final solo necesita descomprimir y ejecutar ./run.sh (o $projectName).');
    print('No requiere Dart, Rust ni dependencias del sistema instaladas.');
  }

  void _copyDir(Directory src, Directory dst) {
    dst.createSync(recursive: true);
    for (final entity in src.listSync(recursive: false)) {
      final name = p.basename(entity.path);
      if (entity is Directory) {
        _copyDir(entity, Directory(p.join(dst.path, name)));
      } else if (entity is File) {
        entity.copySync(p.join(dst.path, name));
      }
    }
  }
}
