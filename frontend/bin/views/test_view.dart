import 'package:frontend/core/ui/layouts/panel.dart';
import 'package:frontend/core/ui/view.dart';

class TestView extends View {
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
      Panel(expand: Expand.all, className: "panel-4"),
      Panel(width: 200, expand: Expand.height, className: "panel-1"),
      Panel(expand: Expand.width, height: 100, className: "panel-2"),
      Panel(width: 100, height: 100, className: "panel-3"),
    ];
  }
}
