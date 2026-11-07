import 'dart:math';
import 'package:frontend/core/ui/controls/container.dart';
import 'package:frontend/cortex_engine.dart';
import '../styles/styles.dart';

class DashboardView extends FluidView {
  DashboardView()
    : super(
        id: "dashboard_view",
        localLayoutRules: dashboardLayoutRules,
        localStyleRules: dashboardStyleRules,
        backgroundColor: const ColorRGBA(233, 238, 242, 255),
      );

  @override
  List<Panel> build() {
    return [
      Panel(
        width: double.infinity,
        height: 0.25,
        padding: EdgeInsets.all(10),
        layout: PanelLayout.vertical,

        children: [CardsRow()],
      ),
      Panel(
        height: 0.3,
        width: double.infinity,
        padding: EdgeInsets.all(10),
        layout: PanelLayout.vertical,
        children: [
          Row(
            gap: 25,
            children: [
              Container(
                styleClass: "container_graphics",
                layoutClass: "container_graphics",
                child: Graphics1(),
              ),
              Container(
                styleClass: "container_graphics container_graphics_v1",
                layoutClass: "container_graphics",
              ),
              Container(
                styleClass: "container_graphics container_graphics_v2",
                layoutClass: "container_graphics container_graphics_v1",
              ),
            ],
          ),
        ],
      ),
      Panel(
        height: 0.4,
        width: double.infinity,
        padding: EdgeInsets.all(10),
        layout: PanelLayout.vertical,
        children: [
          Row(
            children: [
              Container(layoutClass: "panel-foot", styleClass: "panel-foot"),
            ],
          ),
        ],
      ),
    ];
  }
}

class CardsRow extends Row {
  CardsRow() : super(gap: 20, scroll: false) {}

  @override
  List<CortexNode> build() {
    return [
      Card(
        icon: Icons.message,
        value: "6283",
        title: "Mensajes enviados ultima hora",
      ),
      Card(icon: Icons.people, value: "104.295", title: "Contactos activos"),
      Card(icon: Icons.restorePage, value: "18.295", title: "Casos cerrados"),
      Card(icon: Icons.attach_file, value: "75", title: "Reportes generados"),
    ];
  }
}

class Card extends Container {
  final IconData icon;
  final String value;
  final String title;
  Card({required this.icon, required this.value, required this.title})
    : super(layoutClass: "container_cards", styleClass: "container_cards");

  @override
  CortexNode build() {
    return Col(
      mainAlign: MainAlign.center,
      crossAlign: CrossAlign.center,
      gap: 10.0,
      children: [
        Icon(icon, styleClass: "container_labels"),
        Label(text: value, styleClass: "container_labels"),
        Label(text: title, styleClass: "container_labels_title"),
      ],
    );
  }
}

class Graphics1 extends Container {
  Graphics1({super.layoutClass, super.styleClass});

  @override
  void onResize(int maxWidth, int maxHeight) {
    super.onResize(maxWidth, maxHeight);
    if (width <= 0) width = maxWidth;
    if (height <= 0) height = maxHeight;
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    super.onRender(ctx2d, ctx3d);

    if (width <= 0 || height <= 0) return;

    // 4 Parámetros demo (etiqueta, valor, porcentaje y color)
    final params = [
      (
        label: "B1",
        value: 40.0,
        percent: "40%",
        color: const ColorRGBA(41, 128, 185),
      ), // Azul
      (
        label: "F4",
        value: 25.0,
        percent: "25%",
        color: const ColorRGBA(39, 174, 96),
      ), // Verde
      (
        label: "D3",
        value: 20.0,
        percent: "20%",
        color: const ColorRGBA(230, 126, 34),
      ), // Naranja
      (
        label: "J6",
        value: 15.0,
        percent: "15%",
        color: const ColorRGBA(142, 68, 173),
      ), // Púrpura
    ];

    final total = params.fold<double>(0.0, (sum, p) => sum + p.value);
    if (total <= 0) return;

    final isWide = width >= 240;
    final double outerRadius;
    final int centerX;
    final int centerY;

    if (isWide) {
      outerRadius = min((height / 2) - 14, width * 0.26);
      if (outerRadius <= 5) return;
      centerX = x + (outerRadius + 16).toInt();
      centerY = y + height ~/ 2;
    } else {
      outerRadius = min((width / 2) - 14, height * 0.26);
      if (outerRadius <= 5) return;
      centerX = x + width ~/ 2;
      centerY = y + (outerRadius + 14).toInt();
    }

    final innerRadius = outerRadius * 0.58;

    // 1. Dibuja los sectores de la dona con centro 100% transparente
    double currentAngle = 0.0;
    for (final p in params) {
      final sweep = (p.value / total) * 360.0;
      ctx2d.drawRing(
        centerX,
        centerY,
        innerRadius,
        outerRadius,
        currentAngle,
        currentAngle + sweep,
        segments: 40,
        color: p.color,
      );
      currentAngle += sweep;
    }

    // 2. Dibuja las leyendas al lado o debajo según el espacio
    final textColor = currentStyle.textColor ?? const ColorRGBA(30, 35, 45);

    if (isWide) {
      final legendX = centerX + outerRadius.toInt() + 16;
      final startY = centerY - (params.length * 20) ~/ 2;
      for (int i = 0; i < params.length; i++) {
        final p = params[i];
        final itemY = startY + (i * 20);

        // Indicador de color
        ctx2d.drawRoundRect(legendX, itemY + 3, 9, 9, 2.0, color: p.color);

        // Texto de leyenda
        ctx2d.drawText(
          "${p.label} ${p.percent}",
          legendX + 14,
          itemY,
          12,
          textColor,
        );
      }
    } else {
      final startY = centerY + outerRadius.toInt() + 8;
      final halfW = (width - 16) ~/ 2;
      for (int i = 0; i < params.length; i++) {
        final p = params[i];
        final col = i % 2;
        final row = i ~/ 2;
        final itemX = x + 8 + (col * halfW);
        final itemY = startY + (row * 18);

        ctx2d.drawRoundRect(itemX, itemY + 3, 8, 8, 2.0, color: p.color);
        ctx2d.drawText(
          "${p.label} ${p.percent}",
          itemX + 12,
          itemY,
          11,
          textColor,
        );
      }
    }
  }
}
