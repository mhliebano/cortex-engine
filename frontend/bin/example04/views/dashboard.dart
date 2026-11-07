import 'package:frontend/core/ui/controls/container.dart';
import 'package:frontend/cortex_engine.dart';
import '../styles/styles.dart';

class DashboardView extends FluidView {
  DashboardView()
    : super(
        id: "dashboard_view",
        localLayoutRules: dashboardLayoutRules,
        localStyleRules: dashboardStyleRules,
      );

  @override
  List<Panel> build() {
    return [
      Panel(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(16),
        layout: PanelLayout.vertical,
        children: [
          // 1. Barra superior de encabezado
          Row(
            crossAlign: CrossAlign.center,
            children: [
              Col(
                children: [
                  Label(
                    text: "Cortex Metrics Dashboard",
                    styleClass: "dashboard_title",
                  ),
                  Label(
                    text:
                        "Motor de escritorio nativo (Rust / Raylib OpenGL + Pure Dart)",
                    styleClass: "dashboard_subtitle",
                  ),
                ],
              ),
              Spacer(),
              Row(
                crossAlign: CrossAlign.center,
                gap: 8,
                children: [
                  LoadingIndicator(variant: LoadingVariant.pulse, size: 18),
                  Label(
                    text: "En Vivo • 60 FPS",
                    styleClass: "dashboard_subtitle",
                  ),
                ],
              ),
            ],
          ),
          Spacer(16),

          // 2. Fila de 4 tarjetas de métricas responsivas
          CardsRow(),
          Spacer(16),

          // 3. Panel de interacción en vivo
          Row(
            children: [
              Container(
                layoutClass: "panel_section",
                styleClass: "panel_section",
                child: Col(
                  gap: 12,
                  children: [
                    Row(
                      crossAlign: CrossAlign.center,
                      children: [
                        Icon(Icons.dashboard, styleClass: "icon_accent_blue"),
                        Spacer(8),
                        Label(
                          text:
                              "Consola de Pruebas Interactivas (TextField + Selección + Portapapeles)",
                          styleClass: "section_heading",
                        ),
                      ],
                    ),
                    Label(
                      text:
                          "Haz clic en el texto para posicionar el cursor, arrastra para seleccionar, o usa Ctrl+A, Ctrl+C, Ctrl+V y Ctrl+X:",
                      styleClass: "section_subheading",
                    ),
                    Row(
                      crossAlign: CrossAlign.center,
                      gap: 16,
                      children: [
                        TextField(
                          text:
                              "¡Cortex Engine soporta selección y atajos de portapapeles!",
                          layoutClass: "half_width",
                          clearable: true,
                        ),
                        Switch(value: true, label: "GPU VSync"),
                        Slider(
                          value: 60,
                          min: 15,
                          max: 144,
                          label: "Límite FPS",
                        ),
                        Button(
                          text: "Mostrar Diálogo",
                          onClick: () {
                            Dialog.show(
                              "Confirmación de Motor",
                              message:
                                  "¿Deseas reiniciar los contadores de telemetría de Cortex Engine?",
                              icon: Icons.info,
                              onConfirm: () {
                                Toast.show(
                                  "Telemetría restablecida con éxito",
                                  type: ToastType.success,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Spacer(16),

          // 4. Barra de pie / estado del motor
          Row(
            crossAlign: CrossAlign.center,
            gap: 10,
            children: [
              Icon(Icons.checkCircle, styleClass: "icon_accent_green"),
              Label(
                text:
                    "Motor Cortex v1.0.1 • Backend nativo sin WebViews ni Electron",
                styleClass: "dashboard_subtitle",
              ),
              Spacer(),
              LoadingIndicator(variant: LoadingVariant.circular, size: 16),
              Label(text: "Sincronizado", styleClass: "dashboard_subtitle"),
            ],
          ),
        ],
      ),
    ];
  }
}

class CardsRow extends Row {
  CardsRow() : super(gap: 16, scroll: false);

  @override
  List<CortexNode> build() {
    return [
      // Tarjeta 1: Mensajes
      Container(
        layoutClass: "container_cards",
        styleClass: "container_cards",
        child: Col(
          mainAlign: MainAlign.center,
          gap: 6.0,
          children: [
            Row(
              crossAlign: CrossAlign.center,
              children: [
                Icon(Icons.send, styleClass: "icon_accent_blue"),
                Spacer(),
                Badge(label: "+14.2%", styleClass: "badge_up"),
              ],
            ),
            Label(text: "628.3k", styleClass: "card_value"),
            Label(text: "Mensajes enviados", styleClass: "card_title"),
            ProgressBar(value: 0.78, minHeight: 4, styleClass: "progress_blue"),
          ],
        ),
      ),

      // Tarjeta 2: Usuarios Activos
      Container(
        layoutClass: "container_cards",
        styleClass: "container_cards",
        child: Col(
          mainAlign: MainAlign.center,
          gap: 6.0,
          children: [
            Row(
              crossAlign: CrossAlign.center,
              children: [
                Icon(Icons.person, styleClass: "icon_accent_green"),
                Spacer(),
                Badge(label: "En vivo", styleClass: "badge_live"),
              ],
            ),
            Label(text: "1,420", styleClass: "card_value"),
            Label(text: "Usuarios concurrentes", styleClass: "card_title"),
            ProgressBar(
              value: 0.62,
              minHeight: 4,
              styleClass: "progress_green",
            ),
          ],
        ),
      ),

      // Tarjeta 3: Carga GPU / Rendimiento
      Container(
        layoutClass: "container_cards",
        styleClass: "container_cards",
        child: Col(
          mainAlign: MainAlign.center,
          gap: 6.0,
          children: [
            Row(
              crossAlign: CrossAlign.center,
              children: [
                Icon(Icons.speed, styleClass: "icon_accent_orange"),
                Spacer(),
                Badge(label: "2.4ms", styleClass: "badge_neutral"),
              ],
            ),
            Label(text: "18.4%", styleClass: "card_value"),
            Label(text: "Carga de GPU / Frame", styleClass: "card_title"),
            ProgressBar(
              value: 0.18,
              minHeight: 4,
              styleClass: "progress_orange",
            ),
          ],
        ),
      ),

      // Tarjeta 4: Almacenamiento
      Container(
        layoutClass: "container_cards",
        styleClass: "container_cards",
        child: Col(
          mainAlign: MainAlign.center,
          gap: 6.0,
          children: [
            Row(
              crossAlign: CrossAlign.center,
              children: [
                Icon(Icons.settings, styleClass: "icon_accent_purple"),
                Spacer(),
                Badge(label: "24/24", styleClass: "badge_live"),
              ],
            ),
            Label(text: "42.8 GB", styleClass: "card_value"),
            Label(text: "Almacenamiento NVMe", styleClass: "card_title"),
            ProgressBar(
              value: 0.45,
              minHeight: 4,
              styleClass: "progress_purple",
            ),
          ],
        ),
      ),
    ];
  }
}
