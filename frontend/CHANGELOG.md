## 1.0.1

- Reestructuración de la arquitectura de la librería `lib/` en tres capas transparentes:
  - `ffi/`: Bindings C-ABI de bajo nivel y cargador nativo `lib_loader.dart`.
  - `wrappers/`: Wrappers idiomáticos en Dart sobre Raylib (`window.dart`, `graphics2d.dart`, `graphics3d.dart`).
  - `core/`: Motor principal del framework (`Application`, `AppWindow`, `Context2D`, `Context3D`, `Navigator` y subsistema `ui/`).
- Creación de la especificación oficial de pruebas unitarias e integración en `docs/CORE_TESTING_PLAN.md`.
- Sincronización completa SemVer a `1.0.1` entre Backend (Rust), Frontend (Dart), scripts de empaquetado del SDK y la documentación técnica.

## 1.0.0

- Versión inicial pública del motor Cortex Engine.
