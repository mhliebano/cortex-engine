# 🚀 PROJECT CONTEXT: CORTEX ENGINE (FORNITURES)

Documento de contexto general para agentes AI y desarrolladores sobre la arquitectura, estado actual, patrones de diseño y flujo de trabajo del proyecto **Cortex Engine**.

---

## 1. 📐 Visión General y Arquitectura

**Cortex Engine** es un motor híbrido de alto rendimiento para aplicaciones desktop 2D/3D interactivas (diseño de muebles, CAD, simulación 3D y suites MDI).

### **Estructura del Proyecto:**
- **Repositorio Principal (`fornitures`)**: `/home/miguel/Proyectos/hibridos/fornitures`
- **SDK Distribuible**: `/home/miguel/Desarrollo/cortex/sdk`
- **Proyecto de Prueba/App (`taller`)**: `/home/miguel/Proyectos/cortex/taller`

### **Stack Tecnológico:**
1. **Core Nativo (Backend)**: Escrito en **Rust** (`backend/src/`). Compila la librería nativa `libbackend.so` / `backend.dll`.
2. **Capa de Binding FFI**: Enlace de bajo nivel C FFI (`frontend/lib/ffi/`) para gráficos 2D (Raylib/OpenGL), 3D, ventana y captura de inputs.
3. **Frontend & Motor de UI**: Escrito en **Dart** (`frontend/lib/`).
4. **Sistema de UI Declarativo**: Inspirado en Flutter/React (`Element`, `View`, `ViewManager`, `DesktopLayout`, `Column`, `Row`, `Panel`, `TextField`, `Dropdown`, `Button`, `Viewport3D`, etc.).

---

## 2. 🔄 Flujo de Trabajo (Compilación, Sync y Verificación)

Cuando realices cualquier cambio en el motor (`frontend/lib/` o `backend/src/`), sigue estrictamente este ciclo:

```bash
# 1. Compilar el SDK empaquetado
cd /home/miguel/Proyectos/hibridos/fornitures
dart scripts/build_release_sdk.dart

# 2. Sincronizar al directorio local del SDK de desarrollo
rsync -av --delete release/sdk/ ~/Desarrollo/cortex/sdk/

# 3. Validar análisis estático en la aplicación de prueba
cd /home/miguel/Proyectos/cortex/taller
dart analyze
```

---

## 3. 🎨 Sistema de UI y Reglas de Diseño Implementadas

### A. Flex Sizing Declarativo (Responsive Automático)
- **Ancho (`isFlexWidth`)**: `Row`, `Column`, `Panel`, `TextField` y `Viewport3D` son flexibles en ancho por defecto (`!_isWidthFixed || fillWidth`), ocupando el 100% del contenedor o dividiendo el espacio libre equitativamente (50/50 en `Row`) sin requerir banderas `expand: Expand.width` manuales. Controles fijos (`Button`, `Label`) conservan su ancho propio.
- **Alto (`isFlexHeight`)**: Los contenedores (`Row`, `Column`, `Panel`) y controles (`TextField`) ajustan su alto vertical estrictamente a su contenido (`contentHeight`) por defecto (`fillHeight || _isHeightFixed`). **NO** se estiran en vertical a menos que explícitamente se especifique `fillHeight: true`, `expand: Expand.height/all`, `isScrollable: true` o un `height` fijo explícito. Esto previene brechas o huecos vacíos gigantes al redimensionar/maximizar la ventana.

### B. Componente `Dropdown<T>`
- **`maxMenuHeight`**: Límite de alto para menús desplegables (por defecto `220px`).
- **Scroll por Rueda del Mouse & Barra de Arrastre**: Soporte completo de navegación interactiva con la rueda del mouse y scrollbar con drag.
- **Recorte por Scissor (`beginScissor`)**: Previene desbordamiento gráfico fuera del área flotante del menú.
- **Auto-Centrado**: Desplaza automáticamente la vista para centrar la opción actualmente seleccionada al desplegar.
- **Aislamiento de Menú Activo (`static Dropdown? _activeOpenDropdown`)**: Control estático global que evita que otras instancias de `Dropdown` ubicadas debajo del menú flotante intercepten clics o se activen involuntariamente.

### C. Componente `TextField`
- **Alto Fijo**: Alto por defecto de `34px` para proporciones estéticas.
- **Borradores Continuos**: Temporizadores para repetición al mantener presionado `Backspace` / `Delete`.
- **Preservación de Foco y Cursor (`importState`)**: Garantiza la continuidad del foco e ingreso de texto durante llamadas a `rebuild()`.
- **Patrón de Claves Estables (`key`)**: La propiedad `key` debe identificar al campo de manera inmutable (ej. `key: '${selectedBoard.id}_posX'`), **evitando** incluir valores mutables como `${selectedBoard.posX}` en la clave.

### D. Renderizado 3D y Controles (`Viewport3D`)
- **Cámara Orbital**: Rotación por arrastre de mouse derecho y zoom dinámico mediante rueda de mouse.
- **Visualización de Bordes**: Resaltado de bordes/aristas en piezas 3D con colores Tailored (ej. dorado para selección).

---

## 4. 📁 Estructura de Archivos Relevantes

```
frontend/lib/
├── engine/
│   ├── application.dart           # Ciclo de vida de la app
│   ├── context2d.dart             # Dibujado 2D / Raylib primitives
│   ├── context3d.dart             # Rendimiento 3D / Cámara / Mallas
│   ├── input.dart                 # Eventos de teclado y mouse
│   ├── navigator.dart             # Ruteo y gestión de vistas
│   └── ui/
│       ├── element.dart           # Clase base Element (isFlexWidth / isFlexHeight)
│       ├── view.dart              # Gestión de View y rebuild()
│       ├── 3d/viewport_3d.dart    # Canvas / Viewport 3D
│       ├── desktop/               # DesktopLayout, MenuBar, ToolBar, StatusBar
│       ├── interaction/           # TextField, Dropdown, Button, Card, Label, etc.
│       └── layouts/               # Column, Row, Panel
└── ftx/                           # Bindings FFI C/Rust
```

---

## 5. 🛠️ Buenas Prácticas para el Próximo Agente

1. **No pedir permiso al usuario**: El usuario otorgó permisos totales explícitos. Modifica y ejecuta directamente.
2. **Validar siempre con `dart analyze`**: Tras cualquier cambio, ejecuta `build_release_sdk.dart`, `rsync` y valida `dart analyze` en `/home/miguel/Proyectos/cortex/taller`.
3. **Mantener Claves (`key`) Estables**: Al añadir controles interactivos en vistas declarativas, usa identificadores estables sin valores mutables concatenados en el `key`.
4. **Respeta las Reglas de Flex Sizing**: Recuerda que `fillWidth` es implícito en contenedores y `TextField`, pero `fillHeight` requiere declaración explícita para evitar deformaciones verticales.
