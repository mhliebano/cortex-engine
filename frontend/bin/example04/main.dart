import 'package:frontend/core/utils.dart';
import 'package:frontend/cortex_engine.dart';
import './views/dashboard.dart';

void main() async {
  Debugger.showLayout = false;
  final app = Application(
    title: "Mi Dashboard",
    width: 800,
    height: 600,
    flags: WindowFlags.windowMaximized,
  );
  app.registerView(DashboardView());
  await app.run();
}
