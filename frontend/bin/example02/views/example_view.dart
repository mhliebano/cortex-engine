import 'package:frontend/core/ui/ui.dart';

class Example02 extends FluidView {
  Example02() : super(id: 'example_02');

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
        children: [
          Col(children: [Spacer()]),
          Col(children: [Spacer()]),
          Col(children: [Spacer()]),
        ],
      ),
      Panel(
        width: 0.5,
        height: 300.0,
        layout: PanelLayout.vertical,
        children: [
          Row(children: [Spacer()]),
          Row(children: [Spacer()]),
          Row(children: [Spacer()]),
          Row(children: [Spacer()]),
        ],
      ),
      MiPanel(),
      Panel(
        width: 0.5,
        height: double.infinity,
        layout: PanelLayout.vertical,
        children: [
          Row(children: [Spacer()]),
          Row(children: [Spacer()]),
          Row(children: [Spacer()]),
          Row(children: [Spacer()]),
          Row(children: [Spacer()]),
        ],
      ),
      MiPanel(),
    ];
  }
}

class MiPanel extends Panel {
  MiPanel({super.key})
    : super(
        width: 0.25,
        height: double.infinity,
        padding: const EdgeInsets.all(10.0),
        layout: PanelLayout.horizontal,
      );

  @override
  List<StructureNode> build() {
    return [
      Col(children: [Spacer()]),
    ];
  }
}
