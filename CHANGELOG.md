# Changelog

---

## [UNRELEASED]

### Agregado

- **Motor 3D Nativo (Backend y Frontend)**: Implementación completa de capacidades 3D exponiendo más de 40 funciones FFI hacia Dart de forma segura (mediante patrón de Handles/IDs y HashMaps concurrentes).
- **Modelos y Mallas Procedurales**: Soporte para carga de modelos (GLTF, OBJ, etc.) y generación procedural (esferas, cubos, cilindros, conos, planos).
- **Materiales y Texturas Interoperables**: Asignación de texturas del módulo 2D directamente en canales 3D (albedo, normal, emission, metalness, etc.).
- **Shaders Nativos**: Integración completa para carga de shaders personalizados y paso de variables Uniforms (Float, Vec2, Vec3, Vec4, Int, Matrix, Textures).
- **Animaciones 3D**: Soporte para carga, lectura de frames, validación y blending suave de animaciones esqueléticas de modelos.
- **Cámara 3D Avanzada**: Control pre-construido de cámaras con algoritmos nativos (modos: Free, Orbital, Primera Persona, Tercera Persona).
- **Ray-Casting y Picking 3D**: Capacidad para lanzar rayos desde el ratón (Screen-to-World) y verificar colisiones contra Bounding Boxes (AABB) y malla poligonal exacta (`rayHitsModelMesh`).
- **Scene Graph en Dart**: Nuevo sistema nativo (`scene3d.dart`) con clase `Transform3D` y jerarquías de dependencias (`Node3D`) para cálculo de matrices de mundo de forma jerárquica padre-hijo.
- **Álgebra 3D**: Adición del paquete estándar `vector_math` al `pubspec.yaml` del SDK para manipulación de cuaterniones, matrices 4x4 y transformaciones.

### Corregido

- **Fuga de memoria nativa en el caché de texto (`graphics2d`)** [P0-01]: El caché de punteros `Utf8` del render loop crecía sin límite (y `clearStringCache()` nunca se invocaba). Se reemplazó por un **arena por frame** que se resetea en cada cuadro: memoria acotada a lo dibujado en un frame y cero `malloc`/`free` por llamada.
- **Condición de carrera en contadores de audio (`audio.rs`)** [P0-02]: `NEXT_SOUND_ID`/`NEXT_MUSIC_ID` eran `static mut` sin sincronización. Migrados a `AtomicI32` con `fetch_add(Relaxed)`, garantizando IDs únicos entre hilos.
- **Consumo de CPU en reposo** [P1-04]: El bucle principal corría sin límite de FPS. Se añadió **FPS adaptativo** (`SetTargetFPS`): 60 FPS en actividad y baja a 15 FPS tras ~2 s de inactividad, restaurándose al instante con cualquier input.
- **Condiciones de Carrera (Data Races) en `graphics2d`**: Refactorización en la asignación de IDs (`NEXT_TEXTURE_ID`) del backend, migrándolo de variables mutables estáticas inseguras a identificadores `AtomicI32`, previniendo choques durante el uso intensivo FFI. *(Parte del trabajo del motor 3D.)*

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
