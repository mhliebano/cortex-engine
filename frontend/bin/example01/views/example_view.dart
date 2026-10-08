import 'package:frontend/core/ui/ui.dart';

class Example01 extends FluidView {
  Example01() : super(id: 'example_01');

  String textVar = "";

  @override
  void onInit() {
    print('first view');
    super.onInit();
  }

  @override
  List<Panel> build() {
    return [
      Panel(
        width: 0.5,
        height: 300.0,
        padding: EdgeInsets.all(15),
        layout: PanelLayout.vertical,
      ),
      Panel(width: 0.5, height: 300.0, layout: PanelLayout.vertical),
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
}
