# 🚀 Cortex Engine

[![Rust](https://img.shields.io/badge/Rust-000000?style=for-the-badge&logo=rust&logoColor=white)](https://www.rust-lang.org/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Raylib](https://img.shields.io/badge/Raylib-000000?style=for-the-badge&logo=raylib&logoColor=white)](https://www.raylib.com/)
[![GitHub Release](https://img.shields.io/github/v/release/mhliebano/cortex-engine?style=for-the-badge&logo=github)](https://github.com/mhliebano/cortex-engine/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20macOS-blue?style=for-the-badge)](#-descargas-releases)

**Cortex Engine** es un framework híbrido de alto rendimiento para el desarrollo de aplicaciones desktop 2D y 3D (software CAD, simuladores 3D, herramientas de optimización y suites MDI). 

Combina la potencia de renderizado acelerado por GPU de **Rust** (vía la C-ABI nativa de **Raylib**) con la elegancia, orientación a objetos y agilidad del lenguaje **Pure Dart** mediante FFI directa, eliminando por completo la pesada sobrecarga de memoria de Electron y la complejidad de runtime de Flutter Desktop.

---

## 💡 ¿Por qué Cortex Engine?

| Característica | Cortex Engine | Electron | Flutter Desktop |
| :--- | :--- | :--- | :--- |
| **Backend / Gráficos** | Rust (Raylib / OpenGL GPU) | Chromium / Node.js | Skia / Impeller Embedder |
| **Lenguaje Frontend** | Pure Dart (Typed, POO) | JavaScript / TypeScript | Dart |
| **Consumo de Memoria** | **Ultra bajo (< 50MB RAM)** | Alto (> 200MB-500MB RAM) | Medio (> 100MB RAM) |
| **Manejo de Texto FFI** | Zero-Allocation UTF-8 | IPC serialization | Direct Embedder Channel |
| **Capacidades 3D** | Viewport 3D Nativo con Cámara Orbital | WebGL / Three.js | Canvas3D / SceneBuilder |

---

## ✨ Características Clave

- ⚡ **GPU Native Performance**: Backend compilado en Rust como librería dinámicamente enlazada (`libbackend.so` / `backend.dll`), acelerado por hardware OpenGL/Raylib.
- 🎯 **Zero-Allocation FFI Text Rendering**: Caché interna de punteros `Pointer<Utf8>` para fuentes vectoriales TTF/OTF a 60+ FPS estables sin pausas de Recolección de Basura (GC).
- 🧩 **UI Declarativa Flex (Responsive)**: Contenedores inteligentes `Column`, `Row` y `Panel` con ajuste de tamaño flex automático (`fillWidth` / `fillHeight`).
- 🎨 **Sistema de Estilos CSS (`Style`)**: Clases CSS declarativas reutilizables (`className: "btn-primary"`) registradas globalmente.
- 🔊 **Motor de Audio Integrado**: Dispositivo de audio nativo con soporte para efectos de sonido en memoria (`Sound`) y reproducción por streaming de música (`Music`).
- 🧊 **Canvas3D & Cámara Orbital**: Control interactivo 3D con proyección ortográfica/perspectiva y renderizado de mallas (`Viewport3D`).
- 🖥️ **Widgets Desktop MDI**: Componentes nativos de escritorio como `MenuBar`, `ToolBar`, `StatusBar`, `Dropdown<T>` recortado por scissor, y `TextField` con foco persistente.

---

## 📐 Arquitectura del Repositorio

```text
cortex-engine/
├── backend/                  <-- Core Nativo en Rust (Compila libbackend.so / backend.dll)
│   ├── Cargo.toml            # Configuración de Cargo y Raylib C-ABI
│   └── src/                  # Módulos nativos (window, graphics2d, graphics3d, input, audio)
├── frontend/                 <-- Engine Framework & Aplicación en Dart
│   ├── pubspec.yaml          # Dependencias de Dart (ffi, path)
│   ├── assets/               # Fuentes TTF vectoriales e imágenes estáticas
│   ├── lib/                  # Código fuente del Motor (FFI bindings, Layout Flex, UI Widgets, Audio)
│   └── bin/                  # Aplicación de demostración y pruebas
├── scripts/                  # Herramientas CLI y scripts de compilación
│   └── build_release_sdk.dart# Compilador y empaquetador del SDK distribuible
└── docs/                     # Documentación técnica de arquitectura y estructura
```

## 📦 Descargas (Releases)

Si prefieres utilizar **Cortex Engine** directamente sin necesidad de compilar el backend en Rust o los paquetes desde el código fuente, puedes descargar los paquetes SDK precompilados y binarios listos para usar:

- 🚀 **[Última Versión Precompilada (Latest Release)](https://github.com/mhliebano/cortex-engine/releases/latest)**
- 📋 **[Historial de Versiones (All Releases)](https://github.com/mhliebano/cortex-engine/releases)**

---

## ⚙️ Prerrequisitos e Instalación

### 1. Requerimientos del Sistema

- **Rust Toolchain** (edición 2024 o superior):
  ```bash
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  ```
- **Dart SDK** (v3.12.0 o superior):
  [Instrucciones oficiales de Dart SDK](https://dart.dev/get-dart)
- **Librerías de Desarrollo Gráfico (Linux)**:
  En distribuciones basadas en Ubuntu/Debian:
  ```bash
  sudo apt-get update
  sudo apt-get install -y build-essential libasound2-dev libx11-dev libxrandr-dev libxi-dev libgl1-mesa-dev libglu1-mesa-dev libxcursor-dev libxinerama-dev
  ```

---

## 🛠️ Compilación del SDK

El proyecto incluye un script de construcción que compila el backend nativo en Rust, construye el ejecutable CLI `cortex` y empaqueta la distribución del SDK en `release/sdk/`:

```bash
# 1. Clonar el repositorio
git clone git@github.com:mhliebano/cortex-engine.git
cd cortex-engine

# 2. Compilar el backend nativo y empaquetar el SDK
dart scripts/build_release_sdk.dart
```

Una vez completado, encontrarás el SDK listo para ser distribuido en `./release/sdk/`.

---

## 🚀 Inicio Rápido (Quickstart)

Crear una aplicación con **Cortex Engine** es simple y declarativo:

```dart
import 'package:cortex/cortex.dart';

// 1. Vista principal declarativa
class MainView extends View {
  MainView() : super(id: 'main_view');

  @override
  List<Element> build() {
    return [
      Panel(
        className: 'main-panel',
        expand: Expand.all,
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Label(
              text: '¡Bienvenido a Cortex Engine!',
              fontSize: 24,
            ),
            Button(
              className: 'btn-primary',
              label: 'Ejecutar Acción',
              onPressed: () {
                print('¡Botón presionado en Cortex Engine!');
              },
            ),
          ],
        ),
      ),
    ];
  }
}

// 2. Punto de entrada de la aplicación
void main() async {
  // Registrar estilos globales
  Style.register('btn-primary', const Style(
    bgColor: ColorRGBA.accentBlue,
    hoverColor: ColorRGBA.hoverBlue,
    textColor: ColorRGBA.white,
    height: 40,
  ));

  // Instanciar la aplicación
  final app = Application(
    title: 'Mi Aplicación Cortex Engine',
    width: 900,
    height: 600,
  );

  // Registrar rutas y vista inicial
  Navigator.registerRoutes({
    'main': () => MainView(),
  });
  Navigator.initialRoute = 'main';

  // Iniciar bucle principal
  await app.run();
}
```

---

## 📄 Licencia

Este proyecto está bajo la Licencia **MIT**. Consulta el archivo [LICENSE](LICENSE) para más detalles.

---

<p center>
  Desarrollado con ❤️ para aplicaciones desktop nativas de alto rendimiento.
</p>
