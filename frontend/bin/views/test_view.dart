import 'package:frontend/core/ui/ui.dart';

class TestView extends FluidView {
  TestView() : super(id: 'test_view');

  @override
  void onInit() {
    print('init Vista de prueba');
    super.onInit();
  }

  @override
  List<Panel> build() {
    return [
      Panel(
        width: 0.5,
        height: 300.0,
        padding: EdgeInsets.all(15),
        children: [
          Col(children: [Spacer(50)]),
          Row(
            gap: 20,
            children: [
              Label(text: "Bienvenido a Cortex"),
              Label(text: "Es cool!"),
            ],
          ),
          Col(children: [Spacer()]),
        ],
        layout: PanelLayout.vertical,
      ),
      Panel(width: 0.5, height: 300.0),
      MiPanel(),
    ];
  }
}

class MiPanel extends Panel {
  MiPanel({super.key})
    : super(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(10.0),
        layout: PanelLayout.vertical,
      );

  @override
  List<StructureNode> build() {
    return [
      Row(children: [Spacer(50)]),
      Row(children: [Spacer()]),
      Row(children: [Spacer()]),
    ];
  }
}
