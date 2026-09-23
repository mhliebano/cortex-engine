# Raylib Capabilities Checklist — Cortex Engine

Checklist de capacidades de raylib para ir exponiendo vía FFI en `backend/` (Rust) hacia `frontend/` (Dart). Organizado por módulo, siguiendo la estructura actual del repo.

---

## `window` — Core / ventana / monitor

- [ ] Crear/cerrar ventana, título, tamaño, posición, ícono
- [ ] Flags: resizable, fullscreen, maximized, minimized, undecorated, transparent, always-on-top, high-DPI
- [ ] Multi-monitor: listar monitores, mover ventana, obtener refresh rate/resolución
- [ ] VSync, FPS objetivo, `GetFrameTime`, `GetTime`
- [ ] Clipboard (leer/escribir texto)
- [ ] Drag & drop de archivos sobre la ventana
- [ ] Cursor: mostrar/ocultar, atrapar, cambiar forma
- [ ] Captura de pantalla / screenshot a archivo

## `graphics2d` — Dibujo 2D, formas, texturas

- [ ] Formas: líneas, rectángulos (con/sin redondeo), círculos, elipses, triángulos, polígonos, arcos
- [ ] Relleno vs. contorno, gradientes
- [ ] Texturas/Imágenes: carga desde archivo/memoria (PNG, JPG, BMP...), render textures
- [ ] Recorte (`sourceRec`), escalado, rotación, tinte de color, flip H/V
- [ ] Mipmaps, filtrado (point/bilinear)
- [ ] Manipulación de imágenes en CPU: resize, crop, rotate, blur, dithering, combinar imágenes
- [ ] Generación procedural de texturas (ruido, gradientes, checkerboard)
- [ ] NPatch (9-slice) para paneles/botones escalables
- [ ] Scissor mode (recorte por rectángulo) — generalizar a scroll areas
- [ ] Blend modes: alpha, aditivo, multiplicativo

## `text` / `fonts` — (nuevo módulo sugerido, separar de graphics2d)

- [ ] Fuentes por defecto vs. TTF/OTF personalizadas
- [ ] SDF fonts (texto nítido a cualquier escala de zoom)
- [ ] Medición de texto y de glyphs individuales
- [ ] Ajuste de espaciado, wrapping
- [ ] Soporte Unicode/UTF-8

## `graphics3d` — Modelos, mallas, cámara, shaders

- [ ] Cámara 3D: orbital, primera persona, libre, ortográfica/perspectiva
- [ ] Primitivas: cubo, esfera, cilindro, plano, cono, toro
- [ ] Carga de modelos: OBJ, GLTF/GLB, IQM, VOX, M3D
- [ ] Generación procedural de mallas (planos, terrenos por heightmap, esferas paramétricas)
- [ ] Materiales y shaders GLSL custom (post-procesado, outline/highlight de selección)
- [ ] Animación de esqueleto (skeletal animation, IQM/GLTF)
- [ ] rlgl: acceso directo a geometría inmediata (grids, gizmos de manipulación)

## `collision` — (nuevo módulo sugerido)

- [ ] 2D: rect-rect, rect-círculo, punto-rect (hit-testing de UI)
- [ ] 3D: rayo-caja (bounding box), rayo-esfera, rayo-triángulo/malla (selección en Viewport3D)

## `input` — Teclado, mouse, gamepad, touch

- [ ] Teclado: down/pressed/released/up, captura Unicode por frame (`GetCharPressed`)
- [ ] Mouse: posición, delta, botones, rueda (incl. horizontal), cursor por zona
- [ ] Gamepad: detección, botones, ejes analógicos
- [ ] Touch/gestos: tap, swipe, pinch, drag

## `audio` — Ya cubierto en buena parte

- [x] `Sound` (efectos en memoria)
- [x] `Music` (streaming)
- [ ] `AudioStream` crudo (audio generado proceduralmente)
- [ ] Control de pitch/pan por sonido
- [ ] Múltiples dispositivos de salida

## `shaders` — (nuevo módulo sugerido)

- [ ] Post-procesado (blur de fondo para modales, sombras de paneles)
- [ ] Highlighting de selección 3D
- [ ] Exposición declarativa vía `Style` (ej. `shader: 'glow'`)

## `filesystem` — (nuevo módulo sugerido)

- [ ] Verificar extensión de archivo
- [ ] Obtener directorio de trabajo
- [ ] Listar archivos de un directorio
- [ ] Comprobar si un path existe

## `raygui` — (opcional, como referencia)

- [ ] Widgets inmediatos resueltos (sliders, checkboxes, color pickers) — útil como referencia de comportamiento, no necesariamente para usar directo dado el sistema declarativo propio

---

### Notas de priorización sugerida

1. **Alta prioridad**: `collision` (selección de objetos, hit-testing de UI) y `text`/`fonts` como módulo propio con SDF — impacto directo en usabilidad de CAD/MDI.
2. **Media prioridad**: `shaders` para feedback visual (selección, hover, sombras) y `filesystem` para diálogos de archivo custom.
3. **Baja prioridad / opcional**: `raygui` (solo como referencia), `AudioStream` crudo, soporte gamepad.
