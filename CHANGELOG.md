# Changelog

---

## [1.0.1] - 2026-09-18

### Agregado

- **Dart SDK Embebido en Release**: Integración del entorno ejecutable autónomo de Dart SDK en `release/sdk/dart-sdk/` para permitir una instalación y uso "Zero-Setup" sin dependencias previas en la máquina del desarrollador.
- **Soporte de Versión Dinámica en el Empaquetador**: `build_release_sdk.dart` ahora acepta el número de versión deseado como argumento por línea de comandos (ej. `dart scripts/build_release_sdk.dart 1.0.1`).
- **Archivo `analysis_options.yaml`**: Exclusión de directorios `release/` y `dart-sdk/` del análisis estático del editor de código para prevenir escaneos innecesarios del compilador.

### Cambios

- **CLI `cortex` Autónomo**: El ejecutable CLI `cortex` ahora detecta y utiliza de forma prioritaria el binario `dart-sdk/bin/dart` embebido dentro del SDK al ejecutar comandos `cortex run` y `cortex build`.

---

## [1.0.0] - 2026-09-18

### Agregado

- Lanzamiento inicial de **Cortex Engine SDK**.
- Integración nativa de Rust C-ABI (Raylib GPU backend) con frontend de Dart vía FFI.
- Herramienta CLI nativa `cortex` para crear y ejecutar aplicaciones desktop 2D/3D.
- Motor de UI declarativa responsive (`Column`, `Row`, `Panel`, `Viewport3D`, etc.).
