import 'package:frontend/core/ui/controls/container.dart';
import 'package:frontend/core/ui/ui.dart';

class TestView extends FluidView {
  TestView() : super(id: 'test_view');

  String textVar = "";

  @override
  void onInit() {
    print('init Vista de prueba');
    StyleRules.register(
      "label",
      StyleRules(fontSize: 16, textColor: ColorRGBA(255, 0, 0)),
    );
    StyleRules.register("round_corners", StyleRules(borderRadius: 20));
    LayoutRules.register("button", LayoutRules(width: double.infinity));
    StyleRules.register(
      "container",
      StyleRules(
        bgColor: ColorRGBA(255, 255, 255),
        borderColor: ColorRGBA(255, 0, 0),
      ),
    );
    LayoutRules.register(
      "container",
      LayoutRules(width: 0.5, padding: EdgeInsets.all(10)),
    );

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
          Col(
            crossAlign: CrossAlign.center,
            mainAlign: MainAlign.center,
            children: [
              Label(text: "text"),
              Button(text: "button1"),
              Button(text: "button2"),
            ],
          ),
          Row(
            children: [
              Chip(text: "chip1"),
              Chip(text: "chip2"),
              Chip(text: "chip3"),
            ],
          ),
          Col(children: []),
          Row(children: []),
        ],
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
          Col(children: [Image(src: "assets/images/3.png")]),
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
          Chip(text: "fácil"),
          Chip(text: "difícil"),
          Chip(text: "intermedio"),
          Chip(text: "experto"),
          Chip(text: "maestro"),
          Chip(text: "mi casita de galleta iii"),
        ],
      ),
      Row(children: [Spacer()]),
      Row(children: [Spacer()]),
    ];
  }
}
