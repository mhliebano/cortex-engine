# Documentación Oficial de Cortex Engine v1.0.1
*Framework Híbrido 2D/3D de Alto Rendimiento (Pure Dart + Rust Native FFI)*

---

## 1. Visión General y Filosofía

**Cortex Engine** es un motor/framework híbrido diseñado para construir aplicaciones de escritorio 2D y 3D (software CAD, simuladores, optimizadores y juegos) combinando la potencia de renderizado nativo en GPU de **Rust (Raylib C-ABI)** con la elegancia, orientación a objetos y agilidad de **Pure Dart** (sin depender de Flutter Desktop).

### Principios de Diseño:
- **Renderizado Nativo GPU (Rust)**: Raylib compile nativo C-ABI expuesto mediante FFI.
- **Desacoplamiento Total**: La carpeta `frontend/lib/` contiene exclusivamente el motor genérico agnóstico. El código específico de la aplicación (vistas de carpintería, muebles, ajustes) reside en `frontend/bin/`.
- **Cero Basura en GC (FFI Zero-Allocation)**: Reutilización de punteros nativos `Pointer<Utf8>` para cadenas de texto, evitando asignaciones de memoria por frame.
- **Sistema de Estilos CSS (`className`)**: Estilizado mediante clases CSS globales declarativas.
- **Layout Automático y Responsivo**: Disposición mediante `Column` y `Row` sin cálculo manual de coordenadas `x` y `y`.
- **Navegación Global Limpia**: Enrutamiento mediante `Navigator.to('route')` sin referencias circulares hacia la clase `Application`.

---

## 2. Arquitectura del Proyecto

```
cortex/
├── backend/                  <-- MOTOR NATIVO RUST (C-ABI Dylib)
│   └── src/
│       ├── lib.rs            <-- Funciones C-ABI expuestas
│       ├── audio.rs          <-- Sistema nativo de audio (Sound & Music streaming)
│       ├── graphics2d.rs     <-- Renderizado 2D y fuentes vectoriales TTF
│       ├── graphics3d.rs     <-- Cámara 3D orbital, perspectiva/ortográfica y primitivas
│       └── input.rs          <-- Captura de mouse, teclado y buffer de texto
└── frontend/                 <-- APLICACIÓN & FRONTEND DART
    ├── assets/
    │   └── fonts/
    │       └── default_font.ttf <-- Fuente Vectorial TTF (Liberation Sans)
    ├── lib/                  <-- ENGINE CORE (Reutilizable para cualquier proyecto)
    │   ├── ffi/              <-- Capa 1: FFI Low-Level Bindings (audio_bindings, window_bindings, lib_loader)
    │   ├── wrappers/         <-- Capa 2: Native Interop Wrappers (window.dart, graphics2d.dart, graphics3d.dart)
    │   └── core/             <-- Capa 3: Framework Core Engine (Application, AppWindow, Context2D, Context3D, Navigator)
    │       └── ui/           <-- View, Element, Style, Column, Row, Button, Label, Viewport3D, TextField, Panel
    └── bin/                  <-- CÓDIGO DE LA APLICACIÓN ESPECÍFICA
        ├── app_styles.dart   <-- Hoja de Estilos CSS Globales
        ├── main.dart         <-- Punto de Entrada (Init, Register Views & Run)
        └── views/            <-- Pantallas de la App (Editor3DView, CutOptimizerView, ConfigView)

```

---

## 3. Arquitectura del Backend Nativo (Rust)

El backend en Rust compila una librería dinámica nativa (`libbackend.so` en Linux, `backend.dylib` en macOS, `backend.dll` en Windows) que expone funciones de la C-ABI mediante `raylib-sys`.

### Módulos Principales:
- **`audio.rs`**: Gestiona el ciclo de vida del dispositivo de audio nativo, efectos de sonido (`Sound`) pre-cargados en memoria RAM y reproducción de pistas musicales de larga duración por streaming (`Music`). Utiliza wrappers de Rust con concurrencia segura (`Send` + `Sync`) sobre la C-ABI de Raylib.
- **`graphics2d.rs`**: Soporta tipografía vectorial TTF/OTF con `LoadFontEx` y `DrawTextEx` aplicando filtrado bilineal en GPU (`SetTextureFilter(font.texture, 1)`).
- **`graphics3d.rs`**: Permite controlar la posición de la cámara 3D, objetivo, vector `Up`, proyección (Perspectiva u Ortográfica) y dibujado de mallas/cajas 3D.
- **`input.rs`**: Expone coordenadas del puntero del mouse, botones, rueda de desplazamiento, teclas activas y buffer de caracteres (`input_get_char_pressed`).

---

## 4. Frontend en Dart & Optimizaciones FFI

### 4.1 Cargador Nativo (`lib_loader.dart`)
El singleton `LibLoader` localiza dinámicamente el binario compilado en Rust buscando automáticamente en las rutas candidatas:
1. Directorio ejecutable actual `./`
2. `../backend/target/release/`
3. `../backend/target/debug/`

### 4.2 Cuestión de Rendimiento: Cero Asignaciones UTF-8
Para mantener 60 FPS estables sin pausas de Recolección de Basura (GC) en Dart, `Graphics2D` mantiene un `_stringCache` que convierte cadenas de texto a `Pointer<Utf8>` una sola vez y las reutiliza durante el renderizado.

### 4.3 Motor de Audio (`core/audio.dart`)
El motor de audio expone una API orientada a objetos transparente:
- **`AudioEngine`**: Gestiona el dispositivo de audio nativo y el volumen maestro. En cada cuadro (`Application.run`), llama de forma automática a `updateMusic()` para procesar los buffers de streaming sin intervención manual.
- **`Sound`**: Representa clips de sonido cortos (WAV, MP3, OGG) cargados en memoria. Permite controlar `play()`, `stop()`, `pause()`, `resume()`, `volume`, `pitch` y `pan`.
- **`Music`**: Representa pistas musicales de larga duración reproducidas mediante streaming continuo desde disco. Soporta `seek(seconds)`, consulta de `duration` y `timePlayed`.


---

## 5. Sistema de Vistas Orientado a Objetos (POO)

Cada pantalla completa o modo de la aplicación hereda de la clase base `View`.

- **Coordenadas de Origen Fijadas (`x`, `y`)**: Getters de solo lectura (`get x => 0`, `get y => 0`) que garantizan la posición en pantalla completa.
- **Dimensiones Protegidas (`width`, `height`)**: Encapsulados como getters de solo lectura (`_width`, `_height`), gestionados de forma segura por el motor en `onResize()`.
- **Construcción Lazy (`build()`)**: El método `build()` se ejecuta la primera vez que la vista se consulta o inicializa, garantizando la ejecución previa del constructor de la subclase.

```dart
import 'package:cortex/core/ui/interaction/button.dart';
import 'package:cortex/core/ui/layouts/column.dart';
import 'package:cortex/core/ui/interaction/label.dart';
import 'package:cortex/core/ui/layouts/row.dart';
import 'package:cortex/core/ui/view.dart';
import 'package:cortex/core/navigator.dart';

class MiPantallaView extends View {
  MiPantallaView() : super(id: 'mi_pantalla');

  @override
  List<Element> build() {
    return [
      Column(
        fillWidth: true,
        fillHeight: true,
        children: [
          Row(
            className: "header-bar",
            fillWidth: true,
            children: [
              Label(text: "MI PANTALLA CAD", fontSize: 16),
            ],
          ),
          Button(
            className: "btn-primary",
            label: "Ir a Configuración",
            onPressed: () => Navigator.to('config'),
          ),
        ],
      ),
    ];
  }
}
```

### Ciclo de Vida de una `View`:
- **`build()`**: Construye la jerarquía declarativa de elementos de la vista.
- **`onInit()`**: Se ejecuta al registrar o inicializar la vista.
- **`onUpdate(dt, input)`**: Polling de entradas y lógica por frame.
- **`onRender(ctx2d, ctx3d)`**: Renderizado de elementos 2D y Viewports 3D.
- **`onResize(width, height)`**: Recalcula el layout responsivo en caso de cambio de tamaño de la ventana.
- **`onDispose()`**: Limpieza de recursos.

---

## 6. Sistema de Estilos tipo CSS (`className`)

El motor implementa un sistema declarativo de estilos llamado `Style` que se registra globalmente y se asigna mediante la propiedad `className`.

### 6.1 Definición de Clases CSS (`bin/app_styles.dart`)
```dart
void initAppStyles() {
  Style.register('btn-primary', const Style(
    bgColor: ColorRGBA.accentBlue,
    hoverColor: ColorRGBA.hoverBlue,
    textColor: ColorRGBA.white,
    fontSize: 15,
    height: 40,
  ));

  Style.register('sidebar-panel', const Style(
    bgColor: ColorRGBA(30, 34, 42),
    borderColor: ColorRGBA(50, 58, 70),
    padding: 15,
    spacing: 12,
    width: 250,
  ));
}
```

### 6.2 Aplicación en Componentes
Cualquier componente acepta `className`:
```dart
Button(className: "btn-primary", label: "Guardar", onPressed: _save)
Column(className: "sidebar-panel", fillHeight: true, children: [...])
```
*Soporta combinación de clases separadas por espacios (ej. `className: "btn btn-primary"`) y sobrescritura puntual por parámetro.*

---

## 7. Layout Automático y Responsivo (`Column` y `Row`)

El motor elimina la necesidad de calcular coordenadas `x` y `y` a mano mediante contenedores de disposición automática:

- **`Column`**: Apila elementos verticalmente aplicando `padding`, `spacing` y ajustando automáticamente el ancho (`fillWidth`).
- **`Row`**: Alinea elementos horizontalmente aplicando `padding`, `spacing` y ajustando automáticamente el alto (`fillHeight`).

---

## 8. Catálogo de Componentes UI y Módulos del Motor

| Componente / Módulo | Descripción |
| :--- | :--- |
| **`AudioEngine`** | Control global del dispositivo de audio nativo, volumen maestro y refresco automático de streaming. |
| **`Sound`** | Manejo y reproducción de efectos de sonido en memoria RAM (WAV, MP3, OGG). |
| **`Music`** | Reproducción por streaming continuo de música de fondo desde disco, con control de seek y tiempo. |
| **`Viewport3D`** | Lienzo 3D con cámara orbital interactiva, plano de rejilla 3D y renderizado de mallas de muebles/objetos. |
| **`Button`** | Botón interactivo con estados normal, hover y click, texto vectorizado y handler `onPressed`. |
| **`Label`** | Texto vectorial TTF/OTF de alta resolución y nitidez. |
| **`TextField`** | Campo de entrada de texto con foco por clic, cursor parpadeante, borrado (Backspace) y captura de caracteres. |
| **`Panel`** | Contenedor de fondo plano con color de relleno y color de borde. |
| **`Column`** | Contenedor de disposición vertical responsiva. |
| **`Row`** | Contenedor de disposición horizontal responsiva. |


---

## 9. Ejemplo de Entrada Principal (`bin/main.dart`)

```dart
import 'package:cortex/core/application.dart';
import 'app_styles.dart';
import 'views/editor_3d_view.dart';
import 'views/cut_optimizer_view.dart';
import 'views/config_view.dart';

void main() {
  // 1. Inicializar Hoja de Estilos CSS Globales
  initAppStyles();

  // 2. Crear la Aplicación
  final app = Application(
    title: 'Cortex Engine Studio',
    width: 1024,
    height: 768,
  );

  // 3. Registrar las Vistas de la Aplicación
  app.registerView(Editor3DView());
  app.registerView(CutOptimizerView());
  app.registerView(ConfigView());

  // 4. Iniciar el Loop de la Aplicación
  app.run();
}
```
