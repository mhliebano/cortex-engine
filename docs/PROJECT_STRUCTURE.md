# 📁 Estructura Exhaustiva de Archivos y Carpetas del Proyecto Cortex Engine (`fornitures`)

Este documento detalla la estructura **100% completa e integral** de todos los directorios y archivos del repositorio **Cortex Engine**, incluyendo backend nativo en Rust, motor y app en Dart, documentación, scripts de automatización y artefactos compilados de distribución SDK (`release/`).

---

## 🌳 Árbol Completo del Repositorio

```text
fornitures/
├── PROJECT_CONTEXT.md                     # Documento de contexto general del proyecto y flujo de trabajo
├── docs/                                  # Documentación técnica del motor
│   ├── TECHNICAL_DOCUMENTATION.md        # Documentación de arquitectura, FFI, UI y audio
│   ├── PROJECT_STRUCTURE.md              # Estructura exhaustiva de archivos y carpetas
│   └── index.html                         # Portal web de documentación local
├── scripts/                               # Scripts de automatización y compilación
│   └── build_release_sdk.dart            # Empaquetador SDK, generación de CLI y compilación release
├── backend/                               # MOTOR NATIVO RUST (C-ABI Shared Library)
│   ├── Cargo.toml                         # Configuración y dependencias de Rust (raylib-sys, libc)
│   ├── Cargo.lock                         # Bloqueo de versiones de dependencias Rust
│   ├── target/                            # Artefactos compilados por Cargo (debug & release)
│   │   ├── debug/                         # Binarios nativos de desarrollo (libbackend.so)
│   │   └── release/                       # Binarios nativos optimizados para producción (libbackend.so)
│   └── src/                               # Código fuente en Rust
│       ├── lib.rs                         # Punto de entrada de la librería nativa C-ABI
│       ├── audio.rs                       # Motor de audio nativo (Sound & Music streaming)
│       ├── graphics2d.rs                  # Renderizado 2D y gestión de fuentes vectoriales TTF
│       ├── graphics3d.rs                  # Renderizado 3D, cámara orbital y mallas
│       ├── input.rs                       # Captura nativa de eventos de teclado, mouse y texto
│       ├── renderer.rs                    # Control de cuadro (begin_frame, end_frame, clear)
│       └── window.rs                      # Control nativo de ventana GLFW/Raylib
├── frontend/                              # MOTOR Y APLICACIÓN FRONTEND EN DART
│   ├── pubspec.yaml                       # Dependencias de Dart (ffi, path)
│   ├── pubspec.lock                       # Lockfile de paquetes de Dart
│   ├── analysis_options.yaml              # Reglas de análisis linter de Dart
│   ├── README.md                          # Documentación del módulo frontend
│   ├── CHANGELOG.md                       # Historial de cambios
│   ├── .dart_tool/                        # Caché y configuración generada por Dart SDK
│   │   ├── package_config.json            # Mapeo de paquetes locales e impositivos
│   │   └── package_graph.json             # Grafo de dependencias del proyecto
│   ├── assets/                            # Recursos estáticos embebidos
│   │   ├── fonts/                         # Fuentes vectoriales TTF/OTF
│   │   │   ├── default_font.ttf           # Fuente tipográfica base (Liberation Sans)
│   │   │   └── material_icons.ttf         # Fuente de íconos vectoriales
│   │   └── images/                        # Recursos gráficos (1.png, 2.png, 3.png)
│   ├── bin/                               # Código de la aplicación de prueba/ejemplo
│   │   ├── main.dart                      # Punto de entrada de la aplicación de prueba
│   │   ├── app_styles.dart                # Hoja de estilos CSS globales (Style.register)
│   │   └── views/                         # Vistas de la aplicación de prueba
│   │       ├── elements_ui_example.dart   # Vista de demostración de componentes UI
│   │       └── test_view.dart             # Vista de pruebas
│   ├── test/                              # Pruebas unitarias de frontend
│   │   └── rebuild_scroll_test.dart       # Test de scroll y reconstrucción
    └── lib/                               # SDK CORE REUTILIZABLE (Cortex Engine Library)
        ├── audio.dart                     # Barrel export de clases de audio (Sound, Music, AudioEngine)
        ├── graphics2d.dart                # Envoltorio de renderizado 2D en Dart
        ├── graphics3d.dart                # Envoltorio de renderizado 3D en Dart
        ├── renderer.dart                  # Envoltorio de renderer en Dart
        ├── window.dart                    # Envoltorio de ventana en Dart
        ├── libbackend.so                  # Librería compartida nativa compilada en Linux
        ├── ffi/                           # Bindings FFI C-ABI (Capa de bajo nivel)
        │   ├── audio_bindings.dart        # Bindings FFI para funciones nativas de audio
        │   ├── graphics2d_bindings.dart   # Bindings FFI para dibujo 2D y fuentes
        │   ├── graphics3d_bindings.dart   # Bindings FFI para cámara y mallas 3D
        │   ├── input_bindings.dart        # Bindings FFI para entradas de usuario
        │   ├── renderer_bindings.dart     # Bindings FFI para renderizado
        │   ├── window_bindings.dart       # Bindings FFI para gestión de ventana
        │   └── lib_loader.dart            # Carga dinámica singleton de libbackend.so / backend.dll
        └── engine/                        # Motor de UI y aplicación (Capa de alto nivel)
            ├── application.dart           # Bucle principal de la app, ciclo de vida y eventos
            ├── app_window.dart            # Abstracción de ventana y entrada
            ├── audio.dart                 # Clases AudioEngine, Sound y Music
            ├── context2d.dart             # Contexto de renderizado 2D
            ├── context3d.dart             # Contexto de renderizado 3D
            ├── input.dart                 # Motor de captura de input
            ├── navigator.dart             # Enrutador declarativo de vistas (Navigator.to)
            └── ui/                        # Sistema de UI declarativo (Estilo Flutter/React)
                ├── element.dart           # Clase base Element (Flex width/height, layout)
                ├── style.dart             # Sistema de estilos CSS declarativo (Style)
                ├── view.dart              # Clase base View para pantallas completas
                ├── view_manager.dart       # Gestor de vistas activas y ciclo de reconstrucción
                ├── icons.dart             # Constantes y códigos de íconos vectoriales
                ├── layout_alignment.dart  # Alineaciones de layout (MainAxisAlignment, CrossAxisAlignment)
                ├── scroll_controller.dart # Controlador de desplazamientos de scroll
                ├── text_editing_controller.dart # Controlador mutable de campos TextField
                ├── ui.dart                # Barrel export de todo el sistema de UI
                ├── 3d/                    # Componentes UI 3D
                │   └── viewport_3d.dart   # Componente Viewport3D para canvas 3D interactivo
                ├── desktop/               # Componentes de layout de escritorio (MDI)
                │   ├── desktop_layout.dart # Layout de aplicación Desktop MDI
                │   ├── menu_bar.dart      # Barra de menú superior
                │   ├── side_bar.dart      # Barra lateral deslizable/fija
                │   ├── status_bar.dart    # Barra de estado inferior
                │   └── tool_bar.dart      # Barra de herramientas con botones rápidos
                ├── layouts/               # Contenedores de disposición flex
                │   ├── column.dart        # Disposición vertical flexible
                │   ├── row.dart           # Disposición horizontal flexible
                │   └── panel.dart         # Panel contenedor con fondo y borde
                └── interaction/           # Catálogo de widgets interactivos
                    ├── badge.dart         # Insignia/etiqueta flotante de estado
                    ├── button.dart        # Botón interactivo con hover y eventos
                    ├── card.dart          # Tarjeta contenedora elevada
                    ├── carousel.dart      # Carrusel de diapositivas
                    ├── checkbox.dart      # Casilla de verificación booleana
                    ├── chip.dart          # Chip o etiqueta seleccionable
                    ├── dialog.dart        # Ventana emergente modal
                    ├── divider.dart       # Separador lineal horizontal/vertical
                    ├── dropdown.dart      # Menú desplegable interactivo con auto-scroll
                    ├── fab.dart           # Botón de acción flotante (FAB)
                    ├── icon.dart          # Widget de ícono vectorial
                    ├── icon_button.dart   # Botón compacto de ícono
                    ├── image.dart         # Widget de visualización de imágenes
                    ├── label.dart         # Etiqueta de texto de alta resolución
                    ├── list_tile.dart     # Elemento estructurado para listas
                    ├── list_view.dart     # Lista desplazable de elementos
                    ├── loading_indicator.dart # Indicador de carga animado
                    ├── progress_bar.dart  # Barra de progreso lineal
                    ├── radio_button.dart  # Botón de selección única
                    ├── segmented_button.dart # Botón segmentado multiselect
                    ├── slider.dart        # Barra deslizante de rango numérico
                    ├── snack_bar.dart     # Notificación emergente temporal
                    ├── split_button.dart  # Botón dividido con menú flotante
                    ├── switch.dart        # Interruptor de encendido/apagado
                    ├── text_field.dart    # Campo de entrada de texto editable
                    └── toast.dart         # Mensaje flotante de alerta
└── release/                               # PAQUETE DISTRIBUIBLE DEL SDK (Generado por build_release_sdk.dart)
    └── sdk/                               # Cortex Engine Standalone SDK Release Package
        ├── pubspec.yaml                   # Manifest pubspec aislado para el SDK distribuible
        ├── pubspec.lock                   # Lockfile pubspec aislado
        ├── libbackend.so                  # Binario nativo para Linux embebido en la raíz del SDK
        ├── bin/                           # Herramienta de línea de comandos (CLI) del SDK
        │   └── cortex                     # Binario ejecutable nativo CLI (`cortex create`, `cortex run`, `cortex build`)
        ├── docs/                          # Documentación completa empaquetada dentro del SDK
        │   ├── TECHNICAL_DOCUMENTATION.md
        │   ├── PROJECT_STRUCTURE.md
        │   └── index.html
        ├── assets/                        # Recursos y binarios compilados distribuidos
        │   ├── native/                    # Binarios de librerías nativas (.so / .dll)
        │   │   └── libbackend.so
        │   ├── fonts/                     # Fuentes vectoriales embebidas
        │   │   ├── default_font.ttf
        │   │   └── material_icons.ttf
        │   └── images/                    # Imágenes estáticas
        │       ├── 1.png
        │       ├── 2.png
        │       └── 3.png
        └── lib/                           # Código fuente publicado del SDK
            ├── cortex.dart                # Punto de entrada público barrel export principal (`package:cortex/cortex.dart`)
            ├── cortex_engine.dart         # Punto de entrada secundario (`package:cortex/cortex_engine.dart`)
            ├── audio.dart                 # Export de módulos de audio
            ├── graphics2d.dart            # Export de renderizado 2D
            ├── graphics3d.dart            # Export de renderizado 3D
            ├── renderer.dart              # Export de renderizado de frame
            ├── window.dart                # Export de control de ventana
            ├── libbackend.so              # Copia local de la librería dinámica
            ├── ffi/                       # Enlaces FFI compilados
            │   ├── audio_bindings.dart
            │   ├── graphics2d_bindings.dart
            │   ├── graphics3d_bindings.dart
            │   ├── input_bindings.dart
            │   ├── lib_loader.dart
            │   ├── renderer_bindings.dart
            │   └── window_bindings.dart
            └── engine/                    # Estructura del motor de UI y aplicación distribuida
                ├── app_window.dart
                ├── application.dart
                ├── audio.dart
                ├── context2d.dart
                ├── context3d.dart
                ├── input.dart
                ├── navigator.dart
                └── ui/                    # Widgets, layouts y componentes MDI distribuidos
                    ├── element.dart
                    ├── icons.dart
                    ├── layout_alignment.dart
                    ├── scroll_controller.dart
                    ├── style.dart
                    ├── text_editing_controller.dart
                    ├── ui.dart
                    ├── view.dart
                    ├── view_manager.dart
                    ├── 3d/
                    │   └── viewport_3d.dart
                    ├── desktop/
                    │   ├── desktop_layout.dart
                    │   ├── menu_bar.dart
                    │   ├── side_bar.dart
                    │   ├── status_bar.dart
                    │   └── tool_bar.dart
                    ├── interaction/
                    │   ├── badge.dart
                    │   ├── button.dart
                    │   ├── card.dart
                    │   ├── carousel.dart
                    │   ├── checkbox.dart
                    │   ├── chip.dart
                    │   ├── dialog.dart
                    │   ├── divider.dart
                    │   ├── dropdown.dart
                    │   ├── fab.dart
                    │   ├── icon.dart
                    │   ├── icon_button.dart
                    │   ├── image.dart
                    │   ├── label.dart
                    │   ├── list_tile.dart
                    │   ├── list_view.dart
                    │   ├── loading_indicator.dart
                    │   ├── progress_bar.dart
                    │   ├── radio_button.dart
                    │   ├── segmented_button.dart
                    │   ├── slider.dart
                    │   ├── snack_bar.dart
                    │   ├── split_button.dart
                    │   ├── switch.dart
                    │   ├── text_field.dart
                    │   └── toast.dart
                    └── layouts/
                        ├── column.dart
                        ├── panel.dart
                        └── row.dart
```

---

## 📋 Resumen de Directorios Raíz

| Directorio | Descripción |
| :--- | :--- |
| **`PROJECT_CONTEXT.md`** | Guía de arquitectura, comandos de compilación y reglas de UI para desarrolladores y asistentes IA. |
| **`docs/`** | Documentación técnica oficial del motor, arquitectura y estructura de carpetas. |
| **`scripts/`** | Scripts de construcción de releases del SDK (`build_release_sdk.dart`). |
| **`backend/`** | Motor nativo escrito en **Rust**, responsable del renderizado GPU, audio y ventana C-ABI. |
| **`frontend/`** | Motor en **Dart** (`lib/`) y proyecto de pruebas de aplicación (`bin/`). |
| **`release/`** | Artefactos empaquetados finales del SDK distribuible (`release/sdk/`) con el binario CLI `cortex`. |
