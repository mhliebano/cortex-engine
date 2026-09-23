# 📊 Reporte de Estado de Versiones Semánticas (SemVer) — Cortex Engine

**Fecha del análisis:** 23 de Septiembre de 2026  
**Proyecto:** Cortex Engine (Pure Dart + Rust Native FFI)

---

## 1. Resumen Ejecutivo

Tras realizar un análisis integral de las configuraciones de versión en todos los módulos, manifiestos, documentación y scripts de automatización del proyecto **Cortex Engine**, se han identificado **desfases e inconsistencias de versión** entre el módulo nativo Rust (`backend/`), el framework Dart (`frontend/`) y el script empaquetador del SDK (`scripts/`).

Actualmente el proyecto se comercializa/documenta como **`v1.0.0`**, pero existen discrepancias internas que deben corregirse para asegurar una distribución SemVer uniforme.

---

## 2. Matriz de Versiones por Módulo y Archivo

| Módulo / Archivo | Versión Declarada | Estado SemVer | Diagnóstico y Riesgo |
| :--- | :--- | :--- | :--- |
| **`frontend/pubspec.yaml`** | `1.0.0` | ⚠️ Desalineado | Define la versión oficial del paquete Dart SDK (`cortex`). |
| **`backend/Cargo.toml`** | `0.1.0` | ❌ **Desfasado** | Quedó en versión inicial `0.1.0`, desalineado con la release v1.0.0 del motor. |
| **`scripts/build_release_sdk.dart`** | `1.0.1` (fallback) / `1.0.0` (template) | ❌ **Inconsistente** | Usa `1.0.1` por defecto al compilar el SDK, pero inserta `1.0.0` en los templates del CLI. |
| **`README.md`** | `v1.0.0` | ✅ Correcto | Documenta formalmente el motor en versión v1.0.0 Alpha. |
| **`docs/TECHNICAL_DOCUMENTATION.md`** | `v1.0` | ✅ Correcto | Alineado con la versión v1.0 del motor. |
| **`docs/index.html`** | `v1.0` / `1.0.0` | ✅ Correcto | Alineado con la versión pública del SDK. |
| **`frontend/CHANGELOG.md`** | `1.0.0` | ⚠️ Incompleto | Registra `1.0.0 - Initial version.`, sin detallar los cambios de arquitectura recientes. |

---

## 3. Detalle de los Desfases Encontrados

### 3.1 Desfase en Backend Rust (`backend/Cargo.toml`)
* **Problema:** El manifest del paquete nativo C-ABI expone:
  ```toml
  [package]
  name = "backend"
  version = "0.1.0"
  ```
* **Impacto:** En compilaciones de distribución, la librería nativa (`libbackend.so` / `backend.dll`) arrastra metadatos de versión pre-release (`0.1.0`), desfasada del paquete Dart que consume la FFI (`1.0.0`).

### 3.2 Inconsistencia en Script Empaquetador (`scripts/build_release_sdk.dart`)
* **Problema:** El script de construcción del SDK en la línea 4 define:
  ```dart
  final String version = args.isNotEmpty ? args.first : '1.0.1';
  ```
  Sin embargo, en las líneas 236-237 hardcodea la versión `1.0.0` en las plantillas de creación de proyectos CLI.
* **Impacto:** Si un desarrollador ejecuta `dart scripts/build_release_sdk.dart` sin argumentos, el archivo `release/sdk/pubspec.yaml` se genera como `1.0.1`, mientras que el código fuente original de `frontend/pubspec.yaml` continúa marcando `1.0.0`.

### 3.3 Historial de Cambios (`frontend/CHANGELOG.md`)
* **Problema:** No registra la reestructuración de capas `ffi/`, `wrappers/` y `core/` recién implementada.

---

## 4. Plan de Acción Recomendado (Sugerencias de Corrección)

1. **Sincronizar `backend/Cargo.toml`:** Actualizar la versión a `1.0.0`.
2. **Unificar `scripts/build_release_sdk.dart`:** Modificar el script para que lea dinámicamente el campo `version` desde `frontend/pubspec.yaml` en lugar de usar `'1.0.1'` como fallback duro.
3. **Poblar `frontend/CHANGELOG.md`:** Añadir las notas de versión para `1.0.0` incluyendo las mejoras de arquitectura en la capa `core/`.
