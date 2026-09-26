import 'package:frontend/core/ui/ui.dart';

class TestView extends FluidView {
  TestView() : super(id: 'test_view') {
    print('Constructor Vista de prueba');
  }

  @override
  void onInit() {
    print('init Vista de prueba');
    super.onInit();
  }

  @override
  List<Panel> build() {
    return [
      Panel(width: 400, height: 200, className: "panel-1"),
      Panel(width: 300, height: 100, className: "panel-2"),
      Panel(width: 100, height: 100, className: "panel-3"),
      Panel(expand: Expand.width, height: 50, className: "panel-4"),
    ];
  }
}
