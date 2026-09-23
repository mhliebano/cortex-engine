import 'dart:io';

void main(List<String> args) async {
  final String version = args.isNotEmpty ? args.first : '1.0.1';
  final rootDir = Directory.current;
  final frontendDir = Directory('${rootDir.path}/frontend');
  final releaseSdkDir = Directory('${rootDir.path}/release/sdk');

  if (!frontendDir.existsSync()) {
    print('Error: No se encontró la carpeta frontend en ${rootDir.path}');
    exit(1);
  }

  print('🧹 Limpiando y creando carpeta aislada release/sdk (v$version)...');
  if (releaseSdkDir.existsSync()) {
    releaseSdkDir.deleteSync(recursive: true);
  }
  releaseSdkDir.createSync(recursive: true);

  // 1. Copiar lib/
  print('📦 Copiando código del motor de frontend/lib -> release/sdk/lib...');
  _copyDirectory(
    Directory('${frontendDir.path}/lib'),
    Directory('${releaseSdkDir.path}/lib'),
  );

  // 2. Crear barrel exports release/sdk/lib/cortex.dart y release/sdk/lib/cortex_engine.dart
  print(
    '📄 Creando puntos de entrada release/sdk/lib/cortex.dart y cortex_engine.dart...',
  );
  final barrelContent = '''
/// Cortex Engine SDK Barrel File
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
  File(
    '${releaseSdkDir.path}/lib/cortex.dart',
  ).writeAsStringSync(barrelContent);
  File(
    '${releaseSdkDir.path}/lib/cortex_engine.dart',
  ).writeAsStringSync(barrelContent);

  // 3. Copiar librería nativa (.so / .dll) a assets/native/
  print(
    '⚙️ Copiando binarios nativos del motor (libbackend.so / backend.dll) -> release/sdk/assets/native/...',
  );
  final nativeDir = Directory('${releaseSdkDir.path}/assets/native')..createSync(recursive: true);
  final backendDir = Directory('${rootDir.path}/backend/target');
  final libNames = ['libbackend.so', 'backend.dll'];
  for (final name in libNames) {
    File? foundFile;
    final candidateRelease = File('${backendDir.path}/release/$name');
    final candidateDebug = File('${backendDir.path}/debug/$name');
    if (candidateRelease.existsSync()) {
      foundFile = candidateRelease;
    } else if (candidateDebug.existsSync()) {
      foundFile = candidateDebug;
    }

    if (foundFile != null) {
      foundFile.copySync('${nativeDir.path}/$name');
      print('   -> Copiado $name a release/sdk/assets/native/');
    }

  }

  // 4. Copiar assets/, docs/, README.md, LICENSE y CHANGELOG.md
  print('🎨 Copiando recursos de frontend/assets, docs y archivos informativos -> release/sdk/...');
  _copyDirectory(
    Directory('${frontendDir.path}/assets'),
    Directory('${releaseSdkDir.path}/assets'),
  );
  if (Directory('${rootDir.path}/docs').existsSync()) {
    _copyDirectory(
      Directory('${rootDir.path}/docs'),
      Directory('${releaseSdkDir.path}/docs'),
    );
  }
  for (final docFile in ['README.md', 'LICENSE', 'CHANGELOG.md']) {
    final file = File('${rootDir.path}/$docFile');
    if (file.existsSync()) {
      file.copySync('${releaseSdkDir.path}/$docFile');
    }
  }

  // 4b. Copiar Dart SDK embebido para distribución autónoma (Zero-Setup)
  print('🎯 Empaquetando entorno autónomo de Dart SDK -> release/sdk/dart-sdk...');
  final systemDartSdkDir = _findSystemDartSdk();
  if (systemDartSdkDir != null && systemDartSdkDir.existsSync()) {
    final targetDartSdkDir = Directory('${releaseSdkDir.path}/dart-sdk');
    _copyDirectory(
      systemDartSdkDir,
      targetDartSdkDir,
      ignoreFilter: (path) {
        final basename = path.split(Platform.pathSeparator).last;
        return basename.startsWith('dartaotruntime_asan') ||
            basename.startsWith('dartaotruntime_msan') ||
            basename.startsWith('dartaotruntime_tsan');
      },
    );
    print('   -> Dart SDK empaquetado correctamente en release/sdk/dart-sdk');
  } else {
    print('   ⚠️ No se pudo localizar la carpeta completa de Dart SDK para empaquetar.');
  }

  // 5. Crear pubspec.yaml y analysis_options.yaml del SDK
  print('⚙️ Generando release/sdk/pubspec.yaml y analysis_options.yaml (v$version)...');
  File('${releaseSdkDir.path}/pubspec.yaml').writeAsStringSync('''
name: cortex
description: Cortex Engine SDK Standalone Release
version: $version

environment:
  sdk: ^3.12.2

dependencies:
  ffi: ^2.2.0
  path: ^1.9.0
  args: ^2.4.2
  vector_math: ^2.4.3

executables:
  cortex: cortex
''');

  File('${releaseSdkDir.path}/analysis_options.yaml').writeAsStringSync('''
analyzer:
  exclude:
    - 'dart-sdk/**'
    - '.dart_tool/**'
''');

  // 5. Crear CLI bin/cortex.dart
  print('🛠️ Creando herramienta CLI release/sdk/bin/cortex.dart...');
  Directory('${releaseSdkDir.path}/bin').createSync(recursive: true);

  final cliCode = '''#!/usr/bin/env dart
import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  final runner = CommandRunner<void>(
    'cortex',
    'Cortex Engine SDK CLI - Herramienta para crear y compilar proyectos.',
  )
    ..addCommand(CreateCommand())
    ..addCommand(RunCommand())
    ..addCommand(BuildCommand())
    ..addCommand(PubCommand());

  runner.argParser.addFlag(
    'version',
    abbr: 'v',
    negatable: false,
    help: 'Muestra la versión del SDK.',
  );

  try {
    final results = runner.argParser.parse(args);
    if (results['version'] == true) {
      print('Cortex Engine SDK Release v$version');
      return;
    }
    await runner.run(args);
  } on UsageException catch (e) {
    print(e.message);
    print('\\n\${e.usage}');
    exit(64);
  } catch (e) {
    print('Error: \$e');
    exit(1);
  }
}

class CreateCommand extends Command<void> {
  @override
  final String name = 'create';

  @override
  final String description = 'Crea un nuevo proyecto basado en Cortex Engine SDK.';

  CreateCommand() {
    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Directorio de salida para el nuevo proyecto.',
    );
  }

  @override
  Future<void> run() async {
    if (argResults!.rest.isEmpty) {
      print('Error: Proporciona el nombre del proyecto.');
      print('Uso: cortex create <nombre_de_la_app>');
      exit(1);
    }

    final projectName = argResults!.rest.first;
    final sanitizedName = projectName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
    
    final outputDir = argResults!['output'] != null
        ? Directory(argResults!['output'] as String)
        : Directory(p.join(Directory.current.path, projectName));

    if (outputDir.existsSync() && outputDir.listSync().isNotEmpty) {
      print('Error: El directorio "\${outputDir.path}" ya existe y no está vacío.');
      exit(1);
    }

    print('🚀 Creando nuevo proyecto: "\$projectName"...');
    outputDir.createSync(recursive: true);

    final sdkPath = _getSdkPath();

    // 1. Generar cortex.json del SDK (¡0 archivos YAML de Dart!)
    final configContent = """{
  "name": "\${sanitizedName}",
  "version": "$version",
  "engine": "Cortex Engine SDK v$version",
  "dependencies": {}
}
""";
    File(p.join(outputDir.path, 'cortex.json')).writeAsStringSync(configContent);

    // 2. Generar bin/app_styles.dart, bin/views/home_view.dart y bin/main.dart
    final binDir = Directory(p.join(outputDir.path, 'bin'))..createSync();
    final viewsDir = Directory(p.join(binDir.path, 'views'))..createSync();

    final appStylesContent = """import 'package:cortex/cortex.dart';

void initAppStyles() {
  Style.register(
    'header-title',
    const Style(textColor: ColorRGBA.accentBlue, fontSize: 24),
  );

  Style.register(
    'label-muted',
    const Style(textColor: ColorRGBA(130, 145, 165), fontSize: 14),
  );

  Style.register(
    'btn-primary',
    const Style(
      bgColor: ColorRGBA.accentBlue,
      hoverColor: ColorRGBA.hoverBlue,
      textColor: ColorRGBA.white,
      fontSize: 15,
      height: 40,
    ),
  );

  Style.register(
    'panel-container',
    const Style(
      bgColor: ColorRGBA(24, 28, 36),
      padding: 20,
    ),
  );
}
""";
    File(p.join(binDir.path, 'app_styles.dart')).writeAsStringSync(appStylesContent);

    final homeViewContent = """import 'package:cortex/cortex.dart';

class HomeView extends View {
  HomeView() : super(id: 'home');

  @override
  void onInit() {
    super.onInit();
  }

  @override
  List<Element> build() {
    return [
      Panel(
        className: 'panel-container',
        expand: Expand.all,
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.start,
          isScrollable: true,
          children: [
            Label(
              className: 'header-title',
              text: '¡Bienvenido a Cortex Engine!',
            ),
            Label(
              className: 'label-muted',
              text: 'Tu proyecto se ha generado correctamente con el SDK.',
            ),
            Divider(height: 16),
            Button(
              className: 'btn-primary',
              label: 'Comenzar',
              onPressed: () {
                print('¡Hola desde Cortex Engine!');
              },
            ),
          ],
        ),
      ),
    ];
  }
}
""";
    File(p.join(viewsDir.path, 'home_view.dart')).writeAsStringSync(homeViewContent);

    final mainContent = """import 'package:cortex/cortex.dart';
import 'app_styles.dart';
import 'views/home_view.dart';

void main() async {
  initAppStyles();

  final app = Application(
    title: '\${_capitalize(projectName)}',
    width: 800,
    height: 600,
  );

  Navigator.registerRoutes({
    'home': () => HomeView(),
  });

  Navigator.initialRoute = 'home';

  await app.run();
}
""";
    File(p.join(binDir.path, 'main.dart')).writeAsStringSync(mainContent);

    _ensurePackageConfig(outputDir.path, sdkPath);

    print('\\n✨ ¡Proyecto "\$projectName" creado con éxito!');
    print('\\nPara ejecutar tu nueva app:');
    print('  cd \${p.relative(outputDir.path)}');
    print('  cortex run');
  }

  String _getSdkPath() {
    // 1. Revisar la variable de entorno CORTEX_HOME
    final envHome = Platform.environment['CORTEX_HOME'];
    if (envHome != null && envHome.trim().isNotEmpty) {
      final envDir = Directory(envHome.trim());
      if (File(p.join(envDir.path, 'pubspec.yaml')).existsSync()) {
        return envDir.path;
      }
      final parentDir = Directory(p.dirname(envDir.path));
      if (File(p.join(parentDir.path, 'pubspec.yaml')).existsSync()) {
        return parentDir.path;
      }
    }

    // 2. Revisar la ubicación del ejecutable nativo
    try {
      final exePath = File(Platform.resolvedExecutable).resolveSymbolicLinksSync();
      final sdkDir = Directory(p.dirname(p.dirname(exePath)));
      if (File(p.join(sdkDir.path, 'pubspec.yaml')).existsSync()) {
        return sdkDir.path;
      }
    } catch (_) {}

    // 3. Revisar Platform.script
    try {
      final scriptPath = File(Platform.script.toFilePath()).resolveSymbolicLinksSync();
      final sdkDir = Directory(p.dirname(p.dirname(scriptPath)));
      if (File(p.join(sdkDir.path, 'pubspec.yaml')).existsSync()) {
        return sdkDir.path;
      }
    } catch (_) {}

    // 4. Ubicación por defecto en ~/Desarrollo/cortex/sdk
    final userHome = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
    if (userHome.isNotEmpty) {
      final defaultSdk = p.join(userHome, 'Desarrollo', 'cortex', 'sdk');
      if (File(p.join(defaultSdk, 'pubspec.yaml')).existsSync()) {
        return defaultSdk;
      }
    }

    return Directory.current.path;
  }

  void _ensurePackageConfig(String projectPath, String sdkPath) {
    // 1. Eliminar completamente pubspec.yaml y pubspec_overrides.yaml si existieran
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (pubspecFile.existsSync()) {
      try { pubspecFile.deleteSync(); } catch (_) {}
    }
    final overrideFile = File(p.join(projectPath, 'pubspec_overrides.yaml'));
    if (overrideFile.existsSync()) {
      try { overrideFile.deleteSync(); } catch (_) {}
    }

    final projectName = p.basename(projectPath);
    final dartToolDir = Directory(p.join(projectPath, '.dart_tool'))..createSync(recursive: true);
    final packageConfigFile = File(p.join(dartToolDir.path, 'package_config.json'));

    final sdkPackageConfigFile = File(p.join(sdkPath, '.dart_tool', 'package_config.json'));
    final List<Map<String, dynamic>> packages = [
      {
        "name": projectName,
        "rootUri": "../",
        "packageUri": "lib/",
        "languageVersion": "3.12",
      },
      {
        "name": "cortex",
        "rootUri": "file://\$sdkPath",
        "packageUri": "lib/",
        "languageVersion": "3.12",
      },
    ];

    if (sdkPackageConfigFile.existsSync()) {
      try {
        final sdkJson = jsonDecode(sdkPackageConfigFile.readAsStringSync()) as Map<String, dynamic>;
        final sdkPackages = (sdkJson['packages'] as List<dynamic>?) ?? [];
        for (final pkg in sdkPackages) {
          final name = pkg['name'] as String?;
          if (name != null && name != 'cortex' && name != projectName) {
            packages.add(Map<String, dynamic>.from(pkg as Map));
          }
        }
      } catch (_) {}
    }

    // Fallbacks si no estaban resueltos en el SDK
    final packageNames = packages.map((e) => e['name'] as String).toSet();
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
    final pubCache = p.join(home, '.pub-cache', 'hosted', 'pub.dev');

    void addFallback(String name, String dirPattern, String langVersion) {
      if (!packageNames.contains(name)) {
        String packageUri = 'file://\$pubCache/\$dirPattern';
        try {
          final parentDir = Directory(pubCache);
          if (parentDir.existsSync()) {
            final match = parentDir.listSync().firstWhere(
              (e) => p.basename(e.path).startsWith('\$name-'),
              orElse: () => Directory(p.join(pubCache, dirPattern)),
            );
            packageUri = 'file://\${match.path}';
          }
        } catch (_) {}
        packages.add({
          "name": name,
          "rootUri": packageUri,
          "packageUri": "lib/",
          "languageVersion": langVersion,
        });
      }
    }

    addFallback('ffi', 'ffi-2.2.0', '3.7');
    addFallback('path', 'path-1.9.1', '3.4');
    addFallback('args', 'args-2.7.0', '3.3');
    addFallback('vector_math', 'vector_math-2.4.3', '3.0');

    final configMap = {
      "configVersion": 2,
      "packages": packages,
      "generator": "cortex",
    };
    packageConfigFile.writeAsStringSync(jsonEncode(configMap));
  }

  static void _copyDir(Directory src, Directory dst) {
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

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class PubCommand extends Command<void> {
  @override
  final String name = 'pub';
  @override
  final String description = 'Instala las dependencias del proyecto desde cortex.json.';

  @override
  Future<void> run() async {
    final createCmd = CreateCommand();
    final sdkPath = createCmd._getSdkPath();
    final projectPath = Directory.current.path;

    // 1. Leer cortex.json
    final cortexJsonFile = File(p.join(projectPath, 'cortex.json'));
    if (!cortexJsonFile.existsSync()) {
      print('Error: No se encontró cortex.json. ¿Estás en un proyecto Cortex?');
      exit(1);
    }

    final cortexJson = jsonDecode(cortexJsonFile.readAsStringSync()) as Map<String, dynamic>;
    final deps = (cortexJson['dependencies'] as Map<String, dynamic>?) ?? {};
    final projectName = (cortexJson['name'] as String?) ?? p.basename(projectPath);

    // 2. Generar pubspec.yaml temporal
    final buf = StringBuffer();
    buf.writeln('name: \$projectName');
    buf.writeln('environment:');
    buf.writeln('  sdk: ^3.12.2');
    buf.writeln('dependencies:');
    buf.writeln('  cortex:');
    buf.writeln('    path: \$sdkPath');
    for (final entry in deps.entries) {
      buf.writeln('  \${entry.key}: \${entry.value}');
    }

    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    pubspecFile.writeAsStringSync(buf.toString());
    print('📝 pubspec.yaml temporal generado...');

    // 3. Ejecutar dart pub get con el dart embebido
    final dartBin = _getDartExecutable(sdkPath);
    print('📦 Resolviendo dependencias desde pub.dev...');
    final result = Process.runSync(
      dartBin,
      ['pub', 'get'],
      workingDirectory: projectPath,
    );

    if (result.exitCode != 0) {
      print('❌ Error al resolver dependencias:');
      print(result.stderr);
      try { pubspecFile.deleteSync(); } catch (_) {}
      exit(1);
    }

    if ((result.stdout as String).isNotEmpty) print(result.stdout);

    // 4. Limpiar archivos temporales (el usuario nunca los ve)
    try { pubspecFile.deleteSync(); } catch (_) {}
    final lockFile = File(p.join(projectPath, 'pubspec.lock'));
    try { lockFile.deleteSync(); } catch (_) {}

    print('✅ Dependencias instaladas. .dart_tool/package_config.json actualizado.');
  }
}

String _getDartExecutable(String sdkPath) {
  final embeddedDartName = Platform.isWindows ? 'dart.exe' : 'dart';
  final embeddedDart = p.join(sdkPath, 'dart-sdk', 'bin', embeddedDartName);
  if (File(embeddedDart).existsSync()) {
    return embeddedDart;
  }
  return 'dart';
}

class RunCommand extends Command<void> {
  @override
  final String name = 'run';
  @override
  final String description = 'Ejecuta la app Cortex Engine.';

  @override
  Future<void> run() async {
    final mainFile = File(p.join(Directory.current.path, 'bin', 'main.dart'));
    if (!mainFile.existsSync()) {
      print('Error: No se encontró "bin/main.dart".');
      exit(1);
    }
    final createCmd = CreateCommand();
    final sdkPath = createCmd._getSdkPath();
    createCmd._ensurePackageConfig(Directory.current.path, sdkPath);

    final dartBin = _getDartExecutable(sdkPath);
    final process = await Process.start(
      dartBin,
      ['run', 'bin/main.dart'],
      mode: ProcessStartMode.inheritStdio,
    );
    exit(await process.exitCode);
  }
}

class BuildCommand extends Command<void> {
  @override
  final String name = 'build';
  @override
  final String description = 'Compila la app en un ejecutable nativo.';

  @override
  Future<void> run() async {
    final mainFile = File(p.join(Directory.current.path, 'bin', 'main.dart'));
    if (!mainFile.existsSync()) {
      print('Error: No se encontró "bin/main.dart".');
      exit(1);
    }
    final createCmd = CreateCommand();
    final sdkPath = createCmd._getSdkPath();
    createCmd._ensurePackageConfig(Directory.current.path, sdkPath);

    final buildDir = Directory(p.join(Directory.current.path, 'build'))..createSync();
    final projectName = p.basename(Directory.current.path);
    final outputExe = p.join(buildDir.path, projectName);

    print('⚙️ Compilando ejecutable para "\$projectName"...');
    final dartBin = _getDartExecutable(sdkPath);
    final res = Process.runSync(dartBin, ['compile', 'exe', 'bin/main.dart', '-o', outputExe]);
    if (res.exitCode == 0) {
      print('✅ Ejecutable generado: \$outputExe');
    } else {
      print('❌ Error al compilar:\\n\${res.stderr}');
    }
  }
}
''';

  final cliFile = File('${releaseSdkDir.path}/bin/cortex.dart');
  cliFile.writeAsStringSync(cliCode);

  // 6. Ejecutar pub get en release/sdk
  print('📦 Ejecutando dart pub get en release/sdk...');
  final res = Process.runSync('dart', [
    'pub',
    'get',
  ], workingDirectory: releaseSdkDir.path);
  if (res.exitCode != 0) {
    print('⚠️ Error al instalar dependencias en release/sdk:\n${res.stderr}');
  }

  // 7. Compilar ejecutable nativo cortex
  print('⚙️ Compilando binario ejecutable nativo release/sdk/bin/cortex...');
  final compileRes = Process.runSync('dart', [
    'compile',
    'exe',
    cliFile.path,
    '-o',
    '${releaseSdkDir.path}/bin/cortex',
  ], workingDirectory: releaseSdkDir.path);
  if (compileRes.exitCode == 0) {
    print('✅ Binario nativo "cortex" compilado con éxito.');
    // Eliminar el script fuente temporal cortex.dart para dejar solo el binario final
    if (cliFile.existsSync()) {
      cliFile.deleteSync();
    }
  } else {
    print('⚠️ Error al compilar binario cortex:\n${compileRes.stderr}');
  }

  // 8. Empaquetar paquete comprimido release/cortex-sdk.tar.gz
  print('📦 Generando paquete comprimido release/cortex-sdk.tar.gz...');
  final tarRes = Process.runSync('tar', [
    '-czf',
    '${rootDir.path}/release/cortex-sdk.tar.gz',
    '-C',
    '${rootDir.path}/release',
    'sdk',
  ]);
  if (tarRes.exitCode == 0) {
    print('✅ Archivo comprimido generado con éxito: release/cortex-sdk.tar.gz');
  } else {
    print('⚠️ Error al generar tar.gz:\n${tarRes.stderr}');
  }

  print('✅ SDK empaquetado exitosamente en release/sdk');
  print(
    '👉 Para usar los comandos "cortex" y "dart" desde cualquier terminal, agrega la ruta bin a tu PATH:',
  );
  print('   export PATH="\$PATH:${releaseSdkDir.path}/bin:${releaseSdkDir.path}/dart-sdk/bin"');
}

Directory? _findSystemDartSdk() {
  try {
    final exePath = File(Platform.resolvedExecutable).resolveSymbolicLinksSync();
    final flutterDartSdk = Directory('${Directory(exePath).parent.parent.path}/cache/dart-sdk');
    if (flutterDartSdk.existsSync() && File('${flutterDartSdk.path}/bin/dart').existsSync()) {
      return flutterDartSdk;
    }
    final standardSdk = Directory(Directory(exePath).parent.parent.path);
    if (standardSdk.existsSync() &&
        File('${standardSdk.path}/bin/dart').existsSync() &&
        Directory('${standardSdk.path}/lib').existsSync()) {
      return standardSdk;
    }
  } catch (_) {}
  return null;
}

void _copyDirectory(Directory source, Directory destination, {bool Function(String path)? ignoreFilter}) {
  destination.createSync(recursive: true);
  for (var entity in source.listSync(recursive: false)) {
    if (ignoreFilter != null && ignoreFilter(entity.path)) {
      continue;
    }
    final filename = entity.path.split(Platform.pathSeparator).last;
    final newPath = '${destination.path}/$filename';
    if (entity is Directory) {
      _copyDirectory(entity, Directory(newPath), ignoreFilter: ignoreFilter);
    } else if (entity is File) {
      entity.copySync(newPath);
    }
  }
}
