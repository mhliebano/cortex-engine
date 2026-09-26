import 'package:frontend/core/ui/ui.dart';

class TestView extends ContainerView {
  TestView() : super(id: 'test_view');

  @override
  void onInit() {
    print('init Vista de prueba');
    super.onInit();
  }

  @override
  List<Panel> build() {
    return [
      Panel(expand: Expand.width, height: 300, className: "panel-1"),
      Panel(expand: Expand.width, height: 300, className: "panel-2"),
    ];
  }
}
