# Changelog

---

## [UNRELEASED]

### Agregado

- **Patrón de Doble Registro Desacoplado (`StyleRules` & `LayoutRules`)**:
  - Creación de `StyleRules` (`lib/core/ui/style_rules.dart`) para encapsular exclusivamente propiedades cosméticas y de pintura (`bgColor`, `hoverColor`, `textColor`, `borderColor`, `borderRadius`, `fontSize`, etc.).
  - Creación de `LayoutRules` (`lib/core/ui/layout_rules.dart`) para gobernar la matemática espacial, dimensiones y espaciado (`width`, `height`, `minWidth`, `minHeight`, `maxWidth`, `maxHeight`, `padding`, `margin`, `spacing`).
  - Soporte para registro global (`register`) y combinación de clases separadas por espacios (`merge`).

- **Deducción Matemática de Flexibilidad en `ControlNode`**:
  - Eliminadas las banderas booleanas de flexión (`expand`); `ControlNode` ahora deduce reactivamente su comportamiento de resorte en `isFlexWidth` e `isFlexHeight` evaluando si la regla es `double.infinity` o un porcentaje (`> 0.0 && <= 1.0`).
  - Implementación del ciclo de vida `onResize(allocatedWidth, allocatedHeight)` adaptativo para escalar dimensiones por porcentaje, ancho total o píxeles fijos.

- **Componente Contenedor Limpio (`Container`)**:
  - Implementación de `Container` (`lib/core/ui/controls/container.dart`) heredando de `ControlNode` sin parámetros espaciales inline en su constructor.
  - Gestión integral de ciclo de vida (`_updateDimensions`, `onResize`, `onUpdate`, `onRender`, `onRenderOverlay`), soporte de recorte (`Scissor`) y propagación de layout a nodos hijos respetando `padding`.

- **Adaptación y Blindaje de Toda la Suite de Controles (`lib/core/ui/controls/`)**:
  - Refactorización de `Button`, `IconButton`, `TextField`, `Chip`, `Icon`, `Label` e `Image` para adoptar constructores limpios con `styleClass` y `layoutClass`.
  - Protección de `_updateDimensions` contra excepciones de redondeo en dimensiones infinitas (`double.infinity.round()`).
  - Manejo consistente de `onResize` en todos los controles para soportar dimensiones absolutas, porcentuales y de expansión flexible.

- **Componente Campo de Texto (`TextField`) bajo `ControlNode`**:
  - Migración completa de `TextField` a `lib/core/ui/controls/text_field.dart` heredando de `ControlNode`.
  - Captura de clic en control e íconos mediante sobrescritura de `onMouseDown()`, foco global exclusivo (`_activeFocusedTextField`) y dimensiones inicializadas vía `_updateDimensions()`.
  - Soporte completo para entrada de caracteres Unicode, teclas de navegación (`Left`, `Right`, `Home`, `End`), `Enter` y borrado (`Backspace`, `Delete`) con temporizadores de autorrepetición continua.

- **Corrección Crítica en Cola de Entrada Nativa Raylib (`Application`)**:
  - Eliminación de la llamada destructiva `input.getCharPressed() != 0` en el detector de actividad/idle FPS de `application.dart`, la cual desencolaba y descartaba prematuramente los caracteres escritos de Raylib antes de ser procesados por los controles UI.

- **Restauración Recursiva de Estado en Vistas (`View`)**:
  - Implementación de `_restoreElementStates()` en `view.dart` para restaurar de forma transparente los estados (`text`, `isFocused`, `cursorIndex`) en toda la jerarquía de nodos hijos (`TextField`, `Row`, `Col`) ante reconstrucciones de pantalla.

- **Migración y Refactorización de Controles UI a `ControlNode`**:
  - Migración completa de los componentes `Button`, `Chip`, `Icon`, `IconButton`, `Label` e `Image` a la nueva arquitectura `ControlNode` ubicados en `lib/core/ui/controls/`.
  - Encapsulamiento estricto de coordenadas (`x`, `y`) y parámetros de layout dentro del estado interno del nodo, eliminándolos de los constructores públicos y delegando el posicionamiento a los contenedores padres (`Col`, `Row`, `Panel`).
  - Vínculo total con clases CSS (`className`) y resolución dinámica de pseudo-clases en `currentStyle` (`:hover`, `:active`, `:focus`, `:disabled`).

- **Alineación Transversal Predeterminada (`CrossAlign.start`)**:
  - Cambio del valor por defecto de `crossAlign` a `CrossAlign.start` en `Col` y `Row` para evitar la expansión forzada estilo Qt/GTK de los controles hijos.

- **Centralización de Definición `VoidCallback`**:
  - Definición unificada de `typedef VoidCallback = void Function()` en `control_node.dart` para evitar conflictos de exportación.

### Cambiado / Eliminado

- **Eliminación de Componentes Legacy de Interacción**:
  - Eliminados los archivos legacy en `lib/core/ui/interaction/`: `button.dart`, `chip.dart`, `icon.dart`, `icon_button.dart`, `image.dart`, `label.dart` y `text_field.dart`.
  - Actualización de exportaciones centralizadas en `lib/core/ui/ui.dart`.

- **Componente Ficha (`Chip`) y Modelo de Caja**:
  - Creación del componente `Chip` (`chip.dart`) heredando de `ControlNode` como la primera implementación de modelo de caja (`padding`, `bgColor`, `borderColor`, `borderRadius`).
  - Integración de `EdgeInsets` en el tipo de propiedad `Style.padding` (`style.dart`) y consumo directo en la geometría de caja.
  - Centrado horizontal y vertical simétrico de texto dentro del área disponible del chip.

- **Medición Nativa de Texto (`g2d_measure_text`)**:
  - Adición de la función nativa `g2d_measure_text` en el backend en Rust (`graphics2d.rs`), utilizando `MeasureTextEx` de Raylib C API para medir la métrica exacta de glifos en fuentes TTF.
  - Exposición vía FFI en `graphics2d_bindings.dart`, `graphics2d.dart` y `Context2D.measureText`.

- **Nodo Base de Control (`ControlNode`)**:
  - Creación de la clase base abstracta `ControlNode` (`control_node.dart`) heredando directamente de `CortexNode`.
  - Gestión de estado interno de interactividad (`isEnabled`, `isHovered`, `isFocused`) e interceptores de eventos base con guardas de estado.
  - Vínculo dinámico con el sistema de estilos (`Style.merge`) resolviendo pseudoclases CSS en tiempo real con precedencia estricta: `disabled > focus > hover > normal`.

- **Jerarquía Base de Nodos Segregada (`CortexNode`)**:
  - Extraída la clase base abstracta `CortexNode` conteniendo estrictamente las propiedades geométricas puras (`key`, `x`, `y`, `width`, `height`, `isVisible`) y métodos base (`onUpdate`, `onRender`, `onRenderOverlay`, `onResize`).
  - Refactorización de `Element` para heredar de `CortexNode`, desacoplando la base matemática de las propiedades cosméticas y reactivas.
  - Modificación de `StructureNode` y `Panel` para heredar directamente de `CortexNode`.

- **Sistema de Depuración Visual Layout (`Debugger.showLayout`)**:
  - Implementación del Wireframe Debugger en `CortexNode.renderDebugWireframe`.
  - Evaluación de tipos basada en herencia estricta (operador `is`): Rojo para `Panel`, Verde para `Col`, Azul para `Row` y Gris para componentes base.
  - Renderizado de bordes rectangulares del viewport y etiqueta flotante superior izquierda con `runtimeType`.

- **Enums de Flujo y Disposición Direccional**:
  - Definición de los enumeradores universales `MainAlign` (`start`, `center`, `end`, `spaceBetween`, `spaceAround`), `CrossAlign` (`start`, `center`, `end`, `stretch`), `Overflow` (`visible`, `hidden`, `scroll`, `auto`) y `PanelLayout` (`stack`, `vertical`, `horizontal`).

- **Nodos de Flujo Unidireccional (`Col` y `Row`)**:
  - Implementación de las clases `Col` y `Row` heredando de `StructureNode`, exentas de dimensiones absolutas explícitas y márgenes externamente aplicados.

- **Nodo de Espaciado `Spacer`**:
  - Creación del nodo `Spacer([this.size])`. Funcionamiento dual como resorte flexible de expansión en el eje principal (`size == null`) o bloque rígido (`size != null`).

- **Algoritmo de Distribución Matemática Lineal ("Shrink-Wrap" y Resortes)**:
  - Algoritmo de 3 pasos para `Panel` (modos direccionales), `Col` y `Row`:
    1. **Suma Rígida**: Cálculo de componentes fijos, Spacers rígidos y gaps de separación.
    2. **Conteo de Resortes**: Detección de Spacers y nodos flexibles (`isFlexHeight`/`isFlexWidth` o nodos con dimensión inicial sin asignar `0`).
    3. **Repartición y Posicionamiento**: División equitativa del espacio libre entre resortes y posicionamiento secuencial en las coordenadas de origen.
  - **Inmutabilidad Dimensional en `Panel`**: El `Panel` preserva sus dimensiones absolutas o relativas asignadas (cero *shrink-wrap*), dejando espacio libre si los hijos no llenan el contenedor.
  - **Shrink-Wrap Exclusivo**: Ajuste de tamaño total al contenido limitado únicamente a `Col` y `Row` sin resortes flexibles.
  - **Propagación Recursiva de Flexibilidad**: Getters internos transparentes `isFlexHeight` e `isFlexWidth` en `Col`, `Row` y `Spacer`.

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

- **Cálculo Ortogonal de Shrink-Wrap y Propagación de Resortes en `Row`, `Col` y `Panel`**:
  - Medición dinámica del eje transversal (*cross-axis*) en `Row` (altura máxima de hijos) y `Col` (ancho máximo de hijos).
  - Preservación de dimensiones asignadas por contenedores padre (`Panel`), evitando el colapso accidental de ancho/alto.
  - Propagación inteligente de flexibilidad (`isFlexHeight` / `isFlexWidth`) en `Row` y `Col` evaluando si contienen `Spacer` o elementos flexibles para que el `Panel` padre distribuya el espacio sobrante equitativamente.
- **Inicialización de Dimensiones en `Spacer` Rígidos**:
  - Fijadas las dimensiones iniciales `width` y `height` a `size.round()` en `Spacer` cuando se especifica un tamaño numérico explícito.
- **Superposición de Hijos en `Panel`**: Eliminación del reseteo forzado de coordenadas `x`/`y` a `padding` en `Panel.onUpdate()` y `Panel.onRender()`, permitiendo el renderizado secuencial correcto de los elementos organizados por el layout.

### Cambios

- **Refactorización de `Label` sobre `ControlNode`**:
  - Migración de `Label` para heredar de `ControlNode` en lugar de la clase obsoleta `Element`.
  - Eliminación de parámetros obsoletos de layout y resolución dinámica de color y `fontSize` desde `currentStyle`.
- **Saneamiento de la API Pública de Vistas (Minimalismo Ortogonal)**:
  - Privatización de la clase base abstracta `View` a `_View`, eliminando detalles de herencia interna de la capa del usuario final.
  - Renombrado de la vista de lienzo de resolución fija `CanvasView` a `ContainerView`.
  - `FluidView` y `ContainerView` quedan expuestas como las dos únicas entidades públicas concretas del motor para composición e instanciación directa.
  - Depuración de los exports públicos en `ui.dart` para encapsular la estructura base.

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
