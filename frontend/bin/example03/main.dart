import 'package:frontend/core/application.dart';
import 'package:frontend/core/ui/ui.dart';
import 'package:frontend/core/utils.dart';

void main() async {
  Debugger.showLayout = false;

  // 1. Instanciar la aplicación
  final app = Application(
    title: 'Cortex Engine - Example 03',
    width: 250,
    height: 480,
  );

  // 2. Delegar la Tabla de Rutas diferidas (Lazy Loading) al Navigator
  Navigator.registerRoutes({'home': () => MyHomeView()});

  // Configurar la ruta de arranque inicial
  Navigator.initialRoute = 'home';

  // 3. Iniciar la aplicación
  await app.run();
}

class MyHomeView extends ContainerView {
  MyHomeView() : super(id: 'home');

  int _count = 0;

  void incrementCount() {
    _count++;
    rebuild();
  }

  @override
  List<Panel> build() {
    return [
      Panel(
        layout: PanelLayout.vertical,
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        children: [
          Col(
            children: [
              Row(
                mainAlign: MainAlign.center,
                children: [Label(text: 'Cortex demo view')],
              ),
              Col(
                mainAlign: MainAlign.center,
                crossAlign: CrossAlign.center,

                children: [
                  Label(text: 'You have pushed the button'),
                  Label(text: 'this many times:'),
                  Label(text: '$_count'),
                  Button(text: 'Increment', onClick: incrementCount),
                ],
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
