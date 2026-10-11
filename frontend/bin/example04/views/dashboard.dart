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
        padding: EdgeInsets.all(10),
        layout: PanelLayout.vertical,

        children: [
          CardsRow(),
          Row(
            mainAlign: MainAlign.center,
            crossAlign: CrossAlign.center,
            children: [
              Label(text: "Row 2"),
              Label(text: "Row 2.1"),
            ],
          ),
          Row(children: [Label(text: "ROw 3")]),
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
      Col(
        mainAlign: MainAlign.center,
        crossAlign: CrossAlign.center,
        gap: 10.0,
        children: [
          Row(
            children: [
              Icon(Icons.send, styleClass: "container_labels"),
              Label(text: "628.3", styleClass: "container_labels"),
            ],
          ),
          Label(
            text: "Mensajes enviados ultima hora",
            styleClass: "container_labels",
          ),
        ],
      ),
      Container(
        layoutClass: "container_cards",
        styleClass: "container_cards",
        child: Col(
          mainAlign: MainAlign.center,
          crossAlign: CrossAlign.center,
          gap: 10.0,
          children: [
            Row(
              children: [
                Icon(Icons.send, styleClass: "container_labels"),
                Label(text: "628.3", styleClass: "container_labels"),
              ],
            ),
            Label(
              text: "Mensajes enviados ultima hora",
              styleClass: "container_labels",
            ),
          ],
        ),
      ),
      Container(layoutClass: "container_cards", styleClass: "container_cards"),
      Container(layoutClass: "container_cards", styleClass: "container_cards"),
      Container(layoutClass: "container_cards", styleClass: "container_cards"),
    ];
  }
}
