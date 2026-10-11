import 'package:frontend/core/utils.dart';
import 'package:frontend/cortex_engine.dart';
import './views/dashboard.dart';

void main() async {
  Debugger.showLayout = true;
  final app = Application(
    title: "Prueba",
    width: 800,
    height: 600,
    flags: WindowFlags.windowMaximized,
  );
  app.registerView(DashboardView());
  await app.run();
}
