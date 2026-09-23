# 🧪 Batería de Pruebas de Vida Real — Cortex Engine (`lib/core/`)

Casos de uso reales (mal uso, bordes, combinaciones) — no `Style.register('a') → existe`. Cada caso indica **QUÉ HACE HOY el sistema** (verificado ejecutando el motor) y qué debería decidirse.
Marcas: 🔴 crashea · 🟠 falla en silencio / resultado raro · 🟢 comportamiento correcto (fijarlo con test) · ❓ requiere decisión de diseño.

---

## ⚠️ Hallazgos ya confirmados (correr primero)

- 🔴 **`Slider(min > max)` crashea** en el constructor: `ArgumentError: Invalid argument(s): 10.0` (por `value.clamp(min, max)`).
- 🟠 **`Column(padding > width)`** pone el hijo **fuera** del contenedor (`child.x = padding`, ej. 100 con ancho 50) → contenido invisible, sin aviso.
- 🟠 **`Row` sin scroll con hijos que no caben** se salen (`x = 0, 60, 120` con ancho 100) → dibuja fuera de la ventana, sin clip ni aviso.
- 🟠 **`Column` scrollable (o `fillHeight`) anidado en un `Column` sin altura fija** colapsa a `h = 0` → contenido invisible.
- 🟠 **`Navigator.to('ruta-tipeada-mal')`** no hace nada y **no avisa**; igual `ViewManager.switchView('noexiste')` y `Navigator.initialRoute` no registrada → app en blanco sin error.
- 🟠 **`scrollOffset` es campo público sin clamp**: `col.scrollOffset = 99999` se acepta y, además, no dispara re-layout hasta el siguiente frame.
- 🟠 **Dos `DesktopLayout`** → el segundo pisa `activeLayout`; el primero queda huérfano.
- 🟠 **`Label` de texto largo** no recorta ni ajusta: 300 chars → `width = 2100` (se sale).
- 🟠 **`Panel(child: ...fillWidth)` sin tamaño** → `0x0` (padre y hijo invisibles).

---

## 1. Estilos y `className`

- [ ] `[🟢]` Widget con `className` **no registrado** (`Button(className:'zzz')`) → hoy: usa defaults, **no crashea** (Button `80x40`, sin colores).
- [ ] `[🟠]` Igual en `Column(className:'zzz')` → hoy: `spacing=10`, `padding=0` (silencioso). ❓ ¿debería avisar de clase inexistente?
- [ ] `[❓]` `className` registrado **sin** la propiedad que el widget necesita (ej. clase sin `width`) → hoy: cae al default del widget. Decidir si es válido.
- [ ] `[🟠]` **`Style.register('dup')` dos veces** → hoy: sobrescribe sin aviso. ❓ ¿warning de colisión?
- [ ] `[🟢]` `merge('  a   invalida  ')` → hoy: ignora vacíos/clase inexistente, aplica `a`.
- [ ] `[❓]` `merge` con separador tab/`\n` → hoy: **no** separa clases (trata todo como una). ¿Aceptable o issue?

## 2. Layouts bajo presión

### `Column` / `Row`
- [ ] `[🔴]` `Slider` con `min > max` (ver hallazgos) — *es el único crasheo duro encontrado en el core*.
- [ ] `[🟠]` `padding` mayor que el ancho/alto → hijo con `x/y` fuera del contenedor. Decidir: clamp, error o permitido.
- [ ] `[🟠]` `Column(width:-100)` → hoy: `width=-100` se propaga tal cual (negativos aceptados).
- [ ] `[🟠]` `Row(height:-50)` → hoy: `height=-50` aceptado.
- [ ] `[🟠]` Hijos que exceden el tamaño sin `isScrollable` → se salen de la caja (sin clip). ¿Debe recortar?
- [ ] `[❓]` `spacing` negativo (`-8`) → hoy: los hijos **se solapan** (y = 0, 22 con alturas 30). ¿Intencional?
- [ ] `[❓]` Hijos con `height/width = 0` → hoy: ocupan espacio de spacing pero son invisibles. Documentar.
- [ ] `[🟠]` `Column` scrollable **anidado** en `Column` sin altura → colapsa a `0`. Caso típico: panel con lista dentro sin `fillHeight`/tamaño.
- [ ] `[🟠]` `fillHeight:true` en hijo de un `Column` padre sin altura fija → ambos `0`. ¿Quién debe ganar?
- [ ] `[🟢]` `Row` con `mainAxisSize.max` dentro de `Column` → se estira al ancho disponible (correcto).
- [ ] `[🟢]` `mainAxisAlignment.spaceEvenly` con 1 hijo → lo centra (`y=90` en alto 200). Correcto.

### `Panel`
- [ ] `[🟠]` `Panel(child: hijo con fillWidth, sin tamaño)` → `0x0`. Contenedor y contenido desaparecen.
- [ ] `[🟢]` `Panel(child: 40x25)` sin tamaño → panel = `40x25` (auto-dimensiona al hijo).
- [ ] `[🟢]` `Panel(className:'zzz')` → fondo `darkGray`, borde transparente (defaults sanos).

## 3. Navegación y vistas (fallos silenciosos típicos)

- [ ] `[🟠]` `Navigator.to('ruta-tipeada-mal')` → hoy: **no hace nada**, sin log ni excepción. QA real: “navegué y no pasó nada”.
- [ ] `[🟠]` `ViewManager.switchView('noexiste')` → hoy: la vista activa no cambia, sin error.
- [ ] `[🟠]` `Navigator.initialRoute` no registrada → hoy: app arranca **en blanco**, sin aviso.
- [ ] `[🟠]` `Navigator.to` (MDI) a una vista con `children` vacío → hoy: **el `body` no cambia**. Silencioso.
- [ ] `[❓]` Dos `DesktopLayout` → el segundo pisa `activeLayout` (el primero huérfano). ¿Debería haber solo uno?
- [ ] `[🟢]` `registerLazyView` con otra vista activa → NO instancia hasta navegar; 2.º `switchView` reusa (1 sola creación).
- [ ] `[🟢]` `registerLazyView(autoDispose:true)`: salir dispone y volver recrea.
- [ ] `[🟢]` `clear()` y luego `switchView` → no crashea (`activeView=null`).
- [ ] `[🟢]` `Navigator.to('x')` sin handler global y sin MDI → no crashea.

## 4. Controles (interacción real)

- [ ] `[🔴]` **`Slider(min>max)`** → `ArgumentError` en construcción (ver hallazgos).
- [ ] `[🟢]` `Slider(min==max)` → `normalizedValue=0`, no crashea.
- [ ] `[🟢]` `Slider(value:999, min:0, max:100)` → se clampa a 100.
- [ ] `[🟢]` Dos `TextField(isFocused:true)` → el último gana; el primero se desenfoca (no hay “foco fantasma”). Verificar también `TextField.clearActiveFocus()`.
- [ ] `[🟠]` `Dialog.show('t1')` y luego `Dialog.show('t2')` → hoy: reemplaza en silencio; el primer diálogo se pierde. ¿Debe apilar o bloquear?
- [ ] `[🟢]` `Dropdown(options: [])` → construye OK (`220x38`), sin opciones.
- [ ] `[🟢]` `Button(label:'')` → `width=80` (auto-mínimo). `Label(text:'')` → `width=0`.
- [ ] `[🟠]` `Label` con 300 chars → `width=2100` (desborda; sin wrap ni ellipsis).
- [ ] `[🟢]` `enabled:false` en Button/Checkbox/Switch → no disparan callback ni estado hover.
- [ ] `[P1]` `onPressed`/`onChanged` se disparan **1 sola vez** por click (probar doble click y click con drag).

## 5. Scroll (los casos que rompen en producción)

- [ ] `[🟠]` Set programático `col.scrollOffset = 99999` → hoy: se acepta sin clamp **y** el layout queda desfasado hasta el próximo frame. Usar `controller.offset` en su lugar.
- [ ] `[🟢]` `ScrollController` compartido entre 2 `Column` → el offset se sincroniza (probado: 40 en ambos).
- [ ] `[🟢]` Rueda del mouse cuando el contenido cabe (`maxScroll==0`) → no scrollea.
- [ ] `[🟢]` Rueda negativa → **baja** (`offset += 30` por notch), clamp `[0, maxScroll]`.
- [ ] `[❓]` Arrastrar la barra hasta el fondo y soltar fuera de la barra → ¿se libera el drag?
- [ ] `[❓]` `rebuild()` de una vista con scroll activo → ¿se preserva el `offset`? (si no, es bug de UX).

## 6. Ciclo de vida / rebuild

- [ ] `[🟢]` Crear un widget **dentro de `onRender()`** → hoy: lanza `StateError` con mensaje claro. (Buen guard; test de regresión.)
- [ ] `[❓]` `rebuild()` con hijos reordenados **sin `key`** → el estado se asigna por índice de tipo → puede “saltar” al hijo equivocado. Probar y decidir si exigir `key`.
- [ ] `[🟢]` `rebuild()` con `key` → el estado va al elemento correcto.
- [ ] `[🟢]` `Column` no scrollable sin offset → `exportState()` devuelve `null` (no guarda basura).
- [ ] `[❓]` Cambiar de vista **con un `Dialog` abierto** → ¿el modal queda huérfano en pantalla?

## 7. Regresiones de bugs ya resueltos (no deben volver)

- [ ] `[P0-01]` `resetTextArena` tras cada frame → el caché/offset de texto vuelve a 0 (fuga de memoria de texto).
- [ ] `[P0-02]` `AudioEngine.updateMusic` con llamadas repetidas → contadores estables (condición de carrera).
- [ ] `[P0-03]` 3D: límites/parámetros de cámara tras la ampliación.
- [ ] `[P1-04]` FPS adaptativo: ~2s sin actividad → baja a 15 FPS; con input → vuelve a 60.

---

**Para ejecutarlos:** los tests cargan `libbackend.so` (el core la abre en los constructores). Compilar el backend (`cargo build --release`) antes de `dart test`, o marcar estos como `native` y excluirlos. Comando: `cd frontend && dart test`.
