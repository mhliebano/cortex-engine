# 🚀 Cortex Engine

[![Rust](https://img.shields.io/badge/Rust-000000?style=for-the-badge&logo=rust&logoColor=white)](https://www.rust-lang.org/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Raylib](https://img.shields.io/badge/Raylib-000000?style=for-the-badge&logo=raylib&logoColor=white)](https://www.raylib.com/)
[![Status](https://img.shields.io/badge/Status-Alpha%20%7C%20Early%20Stage-orange?style=for-the-badge)]()
[![GitHub Release](https://img.shields.io/github/v/release/mhliebano/cortex-engine?style=for-the-badge&logo=github)](https://github.com/mhliebano/cortex-engine/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

**Cortex Engine** es un framework de escritorio nativo para aplicaciones 2D y 3D, con backend en **Rust + Raylib (OpenGL)** y frontend en **Pure Dart** comunicado mediante FFI directa. 

Sin WebViews, sin Chromium, sin DOM, sin Electron y sin el embedder de Flutter Desktop.

> **⚠️ Estado del proyecto & Aviso de transparencia:** 
> Cortex Engine es un proyecto joven con versión formal v1.0.0. Alimenta funcionalmente proyectos en producción (como *Petsabits* y un *asistente con avatar*), pero se encuentra en fase **Alpha/Early Stage**. Cuenta con una base de sistemas nativa muy sólida pero con limitaciones conocidas en capa de aplicación que detallamos de forma sincerada en este documento.

---

## 🪵 Origen e Historia

Cortex Engine no nació como un intento comercial ni pretencioso de destronar a Flutter ni a Qt (de hecho, me gano el pan trabajando con Flutter). Surgió de una necesidad práctica y personal de autor:

1. **La necesidad original:** Crear una aplicación CAD para diseño de muebles en carpintería y herrería (*Fornitures*). Las alternativas existentes eran obsoletas, costosas y carecían de lógica constructiva real.
2. **La fricción técnica:** Intentar desarrollarlo con Qt o Rust puro implicó pasar más tiempo peleando con la herramienta que resolviendo el problema.
3. **La solución:** Crear un motor nativo ultra-ligero combinando la potencia de Rust/Raylib en el backend con la agilidad de Dart puro en la UI.
4. **Proyectos derivados:** Sobre esta base nacieron **Petsabits** (mascotas de escritorio tipo Tamagotchi corriendo en un *Core 2 Duo con 6GB RAM*) y un **asistente con avatar flotante** (transparente, sin bordes, always-on-top, integrado con LLMs).

---

## ⚖️ Realidad vs. Estado del Proyecto (Tabla Sincerada)

| Área / Característica | Implementación en Cortex Engine | Estado Verificado y Limitaciones Conocidas |
| :--- | :--- | :--- |
| **Backend Gráfico** | Rust compilado a biblioteca dinámica (`libbackend.so` / `backend.dll`) sobre Raylib/OpenGL. | ✅ **Estable.** Renderizado acelerado por GPU con enlace C-ABI. |
| **Frontend UI** | Dart puro (sin Flutter embedder) mediante FFI directa. | ✅ **Estable.** Árbol de widgets declarativo y layout Flex determinista. |
| **Ventana Nativa** | Protocolo EWMH en Linux X11 a bajo nivel (`libX11.so` vía `dlopen`/`dlsym`, sin bordes, transparente, always-on-top). | ✅ **Sólido.** Rama Windows (`user32.dll`) codificada pero pendiente de prueba en hardware real. |
| **Texto FFI (Zero-Allocation)** | Caché de punteros `Pointer<Utf8>` (`_stringCache`). | ⚠️ **Cierto para texto estático.** Texto dinámico de alta rotación requiere política de evicción (en backlog). |
| **Render 3D** | Cámara orbital interactiva (ortográfica y perspectiva), cubos, wireframes y rejilla (`graphics3d.rs`). | ⚠️ **Primitivas.** Carga de mallas complejas (`.obj`/`.gltf`) en roadmap para completar la CAD *Fornitures*. |
| **Subsistema de Audio** | `Sound` (memoria) y `Music` (streaming) en Rust con `IsAudioDeviceReady()`. | ✅ **Funcional.** Fallback silencioso si no hay tarjeta de sonido (no crashea). |
| **Consumo de Memoria** | Huella reducida observada en hardware modesto (Core 2 Duo). | 🟡 **Bajo consumo en reposo** comprobado empíricamente en uso real (benchmark automatizado reproducible en roadmap). |
| **Consumo de CPU en reposo** | Bucle continuo de Raylib a 60 FPS fijos. | ⚠️ **En backlog.** Pendiente regulación de FPS (throttling / modo idle cuando no hay interacción). |
| **Pruebas y CI/CD** | Mínimo test de scroll (`rebuild_scroll_test.dart`). | ❌ **Inexistente.** En proceso de configuración de GitHub Actions y tests unitarios. |

---

## ⚠️ Limitaciones Conocidas Actuales

- **Sin carga de mallas 3D complejas:** El render 3D actual maneja cámara orbital y primitivas (cubos, líneas, grid); la carga de mallas `.obj`/`.gltf` para CAD está en desarrollo.
- **Cache de texto dinámico sin purga automática:** `clearStringCache()` debe invocarse o sustituirse por evicción LRU para textos dinámicos de alta rotación.
- **CPU constante a 60 FPS:** Falta throttling dinámico de framerate en reposo para optimizar consumo de batería en laptops.
- **Pruebas y CI/CD en construcción:** Suite de testing reducida y sin pipelines automatizados de integración continua.
- **Multiplataforma por validar:** Linux X11 es el sistema de referencia totalmente probado. Windows cuenta con implementación de backend nativo pendiente de validación física.

---

## 🎯 Posicionamiento: ¿Cuándo usarlo?

### ✅ Ideal para:
- Herramientas técnicas locales, software CAD ligero y tableros de control.
- Interfaces MDI (Multiple Document Interface) con viewports 3D interactivos.
- Asistentes de escritorio, mascotas virtuales, widgets flotantes y utilidades transparentes *always-on-top*.
- Dispositivos de escasos recursos (hardware modesto/heredado, PCs antiguas, kioscos).
- Desarrolladores que buscan control total de cada píxel y un sistema de estilos ergonómico.

### ❌ No recomendado para:
- Navegadores embebidos o renderizado de HTML/CSS de terceros.
- Aplicaciones que requieran lectores de pantalla o compatibilidad estricta con accesibilidad (A11y).
- Soporte tipográfico bidireccional complejo (árabe, devanagari).
- Proyectos empresariales que requieran un ecosistema masivo de cientos de widgets prefabricados.

---

## 📊 Comparativa con Alternativas

| Característica | Cortex Engine | Electron | Flutter Desktop | Qt / Slint |
| :--- | :--- | :--- | :--- | :--- |
| **Backend / Gráficos** | Rust (Raylib / OpenGL) | Chromium / Node.js | Skia / Impeller | C++ / OpenGL / RHI |
| **Lenguaje Frontend** | Pure Dart (FFI) | JavaScript / TypeScript | Dart | C++ / QML |
| **Consumo de Memoria** | **Bajo (observado en reposo, benchmark en proceso)** | Alto (200MB - 500MB+) | Medio (100MB+) | Bajo - Medio |
| **Estilos UI** | Declarativo tipo CSS (`Style.register`) | CSS / HTML DOM | Widget Properties | QSS / QML / RS |
| **Ventana Transparente / Overlay**| Directo a bajo nivel (X11 / Win32) | Requiere flags / consumo | Complejo | Requiere configuración nativa |
| **Madurez** | Alpha / Early Stage | Muy Madura | Madura | Décadas (Qt) / Joven (Slint) |

---

## 🧱 Arquitectura del Repositorio

```text
cortex-engine/
├── backend/                  <-- Core Nativo en Rust (Compila libbackend.so / backend.dll)
│   ├── Cargo.toml            # Configuración de Cargo y dependencias (Raylib C-ABI)
│   └── src/                  # Módulos nativos (window, graphics2d, graphics3d, input, audio)
├── frontend/                 <-- Framework & Engine UI en Dart Puro
│   ├── pubspec.yaml          # Dependencias (ffi, path)
│   ├── assets/               # Fuentes TTF y recursos
│   ├── lib/                  # Enlaces FFI, layout Flex, catálogo de widgets (20+), audio
│   └── bin/                  # Aplicación de demostración
├── scripts/                  # Scripts de automatización y empaquetado
│   └── build_release_sdk.dart# Compilador y empaquetador del SDK distribuible
└── docs/                     # Documentación técnica
```

---

## 🚀 Inicio Rápido

```dart
import 'package:cortex/cortex.dart';

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
            Label(text: '¡Bienvenido a Cortex Engine!', fontSize: 24),
            Button(
              className: 'btn-primary',
              label: 'Ejecutar Acción',
              onPressed: () => print('¡Botón presionado!'),
            ),
          ],
        ),
      ),
    ];
  }
}

void main() async {
  // Registro de estilos tipo CSS
  Style.register('btn-primary', const Style(
    bgColor: ColorRGBA.accentBlue,
    hoverColor: ColorRGBA.hoverBlue,
    textColor: ColorRGBA.white,
    height: 40,
  ));

  final app = Application(
    title: 'Mi Aplicación Cortex',
    width: 900,
    height: 600,
  );

  Navigator.registerRoutes({'main': () => MainView()});
  Navigator.initialRoute = 'main';

  await app.run();
}
```

---

## ⚙️ Instalación y Compilación

### Opción A: Usar el SDK Precompilado
Descarga el paquete autónomo desde [Releases](https://github.com/mhliebano/cortex-engine/releases), descomprime y agrega los binarios a tu variable de entorno `PATH`:

```bash
export PATH="$PATH:/ruta/a/cortex/release/sdk/bin:/ruta/a/cortex/release/sdk/dart-sdk/bin"
```

### Opción B: Compilar desde el Código Fuente

**Requisitos:** Rust (2024+), Dart SDK (3.12.0+). En Linux, instala las librerías de desarrollo gráfico:

```bash
sudo apt-get install -y build-essential libasound2-dev libx11-dev libxrandr-dev \
  libxi-dev libgl1-mesa-dev libglu1-mesa-dev libxcursor-dev libxinerama-dev
```

**Compilar el SDK:**

```bash
git clone git@github.com:mhliebano/cortex-engine.git
cd cortex-engine
dart scripts/build_release_sdk.dart
```
El SDK compilado estará disponible en `./release/sdk/` y empaquetado en `./release/cortex-sdk.tar.gz`.

---

## 🗺️ Roadmap e Issues Rastreados

Consulta el backlog detallado en el documento de seguimiento: [ISSUES.md](issues/ISSUES.md).

---

## 📄 Licencia

Este proyecto se distribuye bajo la licencia **MIT**.

---

<p align="center">
  Hecho por alguien que quería diseñar muebles y no encontró la herramienta adecuada.<br>
  Sin pretensiones corporativas: solo un carpintero de software creando sus propias herramientas. 🪚⚡
</p>
