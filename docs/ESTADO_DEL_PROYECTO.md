# 📊 Estado General y Estatus del Proyecto — Cortex Engine

> **Fecha del informe:** Noviembre 2026  
> **Versión base:** v1.0.1 (Fase Alpha Avanzada / Early Stage)  
> **Repositorio:** Rama `main` (limpia y sincronizada con `origin/main`)

---

## 1. 📌 Resumen Ejecutivo y Salud Técnica

**Cortex Engine** es un framework de escritorio nativo para aplicaciones 2D y 3D de alto rendimiento. Su arquitectura combina un backend compilado en **Rust + Raylib (OpenGL)** y una capa de interfaz de usuario en **Dart Puro** comunicada mediante llamadas FFI directas de baja latencia, sin intermediación de WebViews, Chromium, Electron ni el embedder de Flutter Desktop.

### Estado de Salud del Código

| Área | Entorno | Diagnóstico | Detalle |
| :--- | :--- | :--- | :--- |
| **Backend Nativo** | Rust / Cargo | ✅ **Saludable** | Compila en <0.1s (`cargo check`). Cero errores, solo 1 warning menor de importación en `input.rs`. |
| **Frontend UI** | Dart SDK | ✅ **Saludable** | Cero errores sintácticos o de tipos (`dart analyze`). Solo observaciones menores de linter. |
| **Control de Versiones** | Git | ✅ **Limpio** | Rama `main` sincronizada con `dev` y `origin/main`. Árbol de trabajo sin cambios pendientes. |

---

## 2. 🧱 Arquitectura y Subsistemas Operativos (¿Por dónde va?)

### A. Backend Nativo (`Rust` + `Raylib 5.5` / `OpenGL`)
* **Gráficos 2D (`graphics2d.rs`):** Renderizado acelerado por GPU, primitivas vectoriales, dibujo de texto, texturas y soporte de recorte con tijeras (`Scissor`).
* **Ventana Nativa (`window.rs`):**
  * **Linux X11:** Control a bajo nivel mediante el protocolo EWMH (`libX11.so` vía `dlopen`/`dlsym`). Soporte verificado para ventanas transparentes, sin bordes, siempre visibles (*always-on-top*), minimizado y maximizado nativo.
  * **Windows:** Enlace a `user32.dll` codificado para gestión de ventanas; pendiente de validación en hardware físico.
* **Subsistema de Audio (`audio.rs`):** Reproducción de efectos (`Sound` en memoria) y pistas largas (`Music` en streaming). Identificadores de pistas protegidos con contadores atómicos (`AtomicI32`) y fallback silencioso si no se detecta hardware de audio.
* **Eficiencia Energética y Throttling:** Bucle interactivo inteligente que reduce automáticamente la tasa de cuadros de 60 FPS a 15 FPS tras 120 frames continuos sin eventos de entrada, restaurando la tasa completa ante cualquier interacción.
* **Gráficos 3D Primitivos (`graphics3d.rs`):** Cámara orbital interactiva (ortográfica y perspectiva), cubos, wireframes, rejilla de referencia (*grid*) y líneas espaciales.

### B. Capa Frontend y Motor de UI (`Dart` Puro + `FFI`)
* **Jerarquía de Nodos Refactorizada:**
  * **`CortexNode`:** Clase base de todos los elementos del árbol de interfaz.
  * **`StructureNode` (`Col`, `Row`, `Panel`, `Splitter`):** Nodos estructurales para maquetación Flex determinista y división redimensionable.
  * **`ControlNode`:** Nodos de interacción y pintura con ciclo de vida completo (`_updateDimensions`, `onResize`, `onUpdate`, `onRender`, `onRenderOverlay`) y gestión de pseudoclases CSS (`:hover`, `:active`, `:focus`, `:disabled`).
* **Patrón de Doble Registro Desacoplado:**
  * **`StyleRules`:** Reglas cosméticas (colores de fondo, bordes, radio, tipografía, color de texto).
  * **`LayoutRules`:** Matemática espacial pura (dimensiones fijas, porcentajes relativos, padding, margin, alineación 2D, gaps).
* **Motor de Layout Flex Determinista:**
  * Dimensiones relativas por porcentaje (`0.25` para 25% del contenedor padre).
  * Expansión dinámica (`double.infinity`).
  * Abrazo estricto de hijos (*rigid sum*) en el eje principal para evitar desbordes no intencionados.
  * Reparto proporcional y seguro del remanente en una sola pasada.
  * **Alineación 2D (`Alignment2D` / `Alignment`):** 9 puntos de anclaje (`topLeft`, `center`, `bottomRight`, etc.) integrados directamente en `Container` y `LayoutRules`.

---

## 3. 🧩 Catálogo de Controles e Inventario UI

### ✅ Controles y Estructuras Completamente Migrados (`ControlNode` / `StructureNode`)
Ubicados en `frontend/lib/core/ui/controls/`, `layouts/` y `desktop/`:
* **Estructurales (`StructureNode`):**
  * **`Col` / `Row`:** Disposición Flex determinista con reparto en una pasada, abrazo rígido de hijos y alineación transversal/principal.
  * **`Panel`:** Contenedor de paneles con soporte de división y agrupamiento de estructuras.
  * **`Splitter` (`SplitPanel`):** Divisor redimensionable por arrastre horizontal/vertical con límites mínimos (`minFirst`, `minSecond`) y persistencia de estado.
  * **`DesktopLayout`:** Armazón integral de escritorio MDI con anclaje automático de barras (`MenuBar`, `ToolBar`, `SideBar`, `StatusBar`) y zona central de trabajo fluida (`body`).
* **Suite de Escritorio (`ControlNode`):**
  * **`MenuBar`:** Menús desplegables multinivel en capa flotante (*overlay*) con atajos de teclado visuales (*accelerators*).
  * **`ToolBar`:** Barra de herramientas de acceso rápido para acciones, iconos y botones.
  * **`SideBar`:** Panel lateral expandible/colapsable para navegación o herramientas de diseño.
  * **`StatusBar`:** Barra de estado inferior con paneles informativos (FPS, métricas, zoom).
* **Controles Interactivos (`ControlNode`):**
  * **`Container`:** Contenedor estilizable con padding, recorte y alineación espacial 2D de su hijo.
  * **`Button` / `IconButton`:** Botones con soporte de iconos, etiquetas y estilos reactivos.
  * **`Icon` / `Label` / `Image`:** Componentes esenciales de contenido visual y textual.
  * **`Chip` / `Badge`:** Píldoras de estado e insignias (tanto independientes como superpuestas en la esquina de otro control).
  * **`Checkbox`:** Casilla de verificación con soporte tri-estado (`true`, `false`, `null` indeterminado).
  * **`RadioButton` / `RadioGroup`:** Selectores de opción única mutuamente excluyentes agrupados por valor.
  * **`Switch`:** Conmutador deslizable con animación interpolada del actuador (*thumb*).
  * **`Slider`:** Deslizador numérico para valores continuos y discretos por divisiones.
  * **`Divider`:** Separador visual horizontal y vertical con soporte de sangrías (*indent*).
  * **`Dropdown`:** Menú desplegable con proyección en capa flotante (*overlay*), auto-scroll y rueda de ratón.
  * **`TextField`:** Entrada de texto con soporte multilínea, selección de rango por ratón y teclado (`Shift`), portapapeles nativo (`Ctrl+C`, `Ctrl+V`, `Ctrl+X`), `Ctrl+A`, posicionamiento de cursor por clic en cualquier posición del texto, foco exclusivo y autorrepetición de teclas.
  * **`ProgressBar`:** Barra de progreso lineal con modos determinado e indeterminado animado, cabecera y porcentajes.
  * **`LoadingIndicator`:** Indicador de carga animado de alta fidelidad con 4 variantes (`circular`, `spinner`, `dots`, `pulse`).
  * **`Dialog`:** Ventana modal emergente con telón de fondo (`backdrop`), botones de acción polimórficos y soporte de hijos `CortexNode`.
  * **`Toast`:** Notificaciones flotantes semánticas con autodestrucción y tipado (`info`, `success`, `warning`, `error`).
  * **`SnackBar`:** Banner de notificación inferior con acción interactiva ("DESHACER", etc.) y botón de cierre.
  * **`SegmentedButton`:** Grupo conectado de botones con selección simple y múltiple, redondeo perimetral y estilo reactivo.
  * **`SplitButton`:** Botón dividido con acción principal izquierda y menú desplegable flotante derecho en `onRenderOverlay`.
  * **`Fab`:** Botón flotante estándar y extendido (`Fab.extended`) con elevación y sombras.
  * **`ListTile`:** Ítem de lista con soporte polimórfico de nodos hijos `CortexNode` en `leading` y `trailing`, títulos y selección.
  * **`Carousel`:** Carrusel animado con paginación fluida, autoPlay, controles flotantes y píldoras indicadoras.
* **Componentes Clave de Productividad y CAD (`ControlNode` / `StructureNode`):**
  * **`TabBar` / `TabView`:** Navegación por pestañas multi-documento con resaltado de pestaña activa, cierre individual `x`, indicador de no guardado (`isModified`), botón `+` para nueva pestaña y auto-scroll horizontal.
  * **`TreeView<T>`:** Árbol jerárquico virtualizado con ramas colapsables/expandibles, líneas guía de jerarquía (`showGuides`), conmutador de visibilidad 3D por pieza/capa (ojo `Icons.visibility`), scroll vertical y callbacks de selección/contextMenu.
  * **`DataGrid<T>`:** Tabla de datos para listas de corte y despiece (BOM) con cabecera ordenable (`▲`/`▼`), columnas redimensionables por arrastre de bordes, coloreado cebra alterno (*zebra striping*), recorte estricto de celdas por tijera y desplazamiento vertical y horizontal.
* **Componentes Gráficos 3D (`ControlNode`):**
  * **`Viewport3D`:** Lienzo tridimensional GPU para visualización y CAD, con cámara orbital interactiva (`enableControls`), rejilla (`showGrid`), ejes (`showAxes`), soporte para trazado de rayos (*Picking 3D*) y HUD 2D superpuesto.

### 🎉 Estado de Migración de UI
**100% de los controles y estructuras han sido migrados a `ControlNode` y `StructureNode`**. La carpeta legacy `lib/core/ui/interaction/` ha sido eliminada por completo, erradicando toda deuda técnica de la arquitectura antigua `Element`.

---

## 4. ⚡ Eficiencia Energética y Reposo Absoluto (*Idle Stop* a 0% CPU)
* **Aceleración y Desaceleración Inteligente**: El bucle principal en `Application` monitoriza deltas del ratón (`mouseX`, `mouseY`), clics, scroll wheel, pulsaciones de teclas y redimensionamiento.
* **Escalonamiento de 3 Etapas**:
  1. **60 FPS**: Modo activo ante cualquier interacción del usuario o animación.
  2. **15 FPS**: Reposo intermedio tras 120 cuadros (~2 s) continuos sin input.
  3. **0.0% CPU**: Reposo profundo pasivo tras 240 cuadros (~5 s) de inactividad, cediendo los ciclos del hilo al sistema operativo (`Future.delayed(66ms)`) y restaurándose instantáneamente a 60 FPS en el mismo cuadro ante el menor movimiento del ratón.

---

## 4. 🔬 Estado de Trabajo Reciente (`example04`)

En `frontend/bin/example04/` se encuentra la suite de prueba activa de la maqueta fluida:
* **`DashboardView`:** Vista fluida que valida la disposición de filas anidadas (`CardsRow`), columnas internas y alineación 2D.
* **Validación de Tarjetas:** Uso de `Container` con la regla de layout `"container_cards"` (`width: 0.25`, `height: double.infinity`, `align: Alignment.center`) y estilos redondeados con bordes.
* **Casos de prueba resueltos:** El centrado vertical y transversal de filas con `MainAlign.center` y `CrossAlign.center` dentro de columnas elásticas.

---

## 5. 📋 Backlog Pendiente y Próximos Pasos

### 🟢 Infraestructura, Testing y Plataforma
1. **Testing y Automatización CI/CD:**
   * Crear suite de tests unitarios en Dart para el motor de layout Flex y resolución de reglas.
   * Configurar pipeline de GitHub Actions para verificación y compilación cruzada en Linux y Windows.
2. **Validación Multiplataforma:**
   * Pruebas en hardware o máquina virtual Windows 10/11 para validar la rama nativa Win32 (`user32.dll`).
3. **Empaquetado y Distribución:**
   * Scripts para empaquetar ejecutables independientes en Linux (`AppImage`, paquete `.deb`) y Windows (`.zip` portable).

