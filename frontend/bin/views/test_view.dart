import 'package:frontend/core/ui/ui.dart';

class TestView extends FluidView {
  TestView() : super(id: 'test_view');

  String textVar = "";

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
          Col(
            children: [
              Label(text: "Es cool!", className: "text"),
              Button(
                text: "Click!",
                onClick: () {
                  print("click by $textVar");
                },
              ),
            ],
          ),
          Row(
            gap: 20,
            overflow: Overflow.scroll,
            children: [
              Label(text: "Bienvenido a Cortex", className: "text-h1"),
              Icon(Icons.access_alarm, className: "icon-class"),
            ],
          ),
          Col(children: [Image(src: "assets/images/2.png")]),
        ],
        layout: PanelLayout.vertical,
      ),
      Panel(
        width: 0.5,
        height: 300.0,
        layout: PanelLayout.vertical,
        children: [
          Row(
            overflow: Overflow.visible,
            children: [
              IconButton(
                icon: Icons.save,
                onClick: () {
                  print("click");
                },
                className: "icon-class",
              ),
              IconButton(
                icon: Icons.settings,
                onClick: () {
                  print("click");
                },
              ),
              IconButton(
                icon: Icons.check_box,
                onClick: () {
                  print("click");
                },
              ),
            ],
          ),
          Row(
            gap: 10,
            overflow: Overflow.scroll,
            children: [
              TextField(
                placeholder: "user",
                onChanged: (val) {
                  textVar = val;
                  print("TextField value: $val");
                },
              ),
              TextField(placeholder: "email"),
            ],
          ),
          Spacer(),
          Col(
            children: [
              Image(src: "assets/images/3.png", className: "image-class"),
            ],
          ),
        ],
      ),
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
      Row(
        gap: 10,
        children: [
          Chip(text: "fácil", className: "chip-class"),
          Chip(text: "difícil", className: "chip-class"),
          Chip(text: "intermedio", className: "chip-class"),
          Chip(text: "experto", className: "chip-class"),
          Chip(text: "maestro", className: "chip-class"),
          Chip(text: "mi casita de galleta iii", className: "chip-class"),
        ],
      ),
      Row(children: [Spacer()]),
      Row(children: [Spacer()]),
    ];
  }
}
