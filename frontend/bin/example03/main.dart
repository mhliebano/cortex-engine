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
  MyHomeView() : super(id: 'home', backgroundColor: ColorRGBA(255, 255, 255)) {
    StyleRules.register(
      "label-header",
      StyleRules(fontSize: 28, textColor: ColorRGBA(0, 0, 255)),
    );
    StyleRules.register(
      "label-body",
      StyleRules(textColor: ColorRGBA(0, 0, 0)),
    );
  }

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
                crossAlign: CrossAlign.center,
                children: [
                  Label(text: 'Cortex demo view', styleClass: "label-header"),
                ],
              ),
              Col(
                mainAlign: MainAlign.center,
                crossAlign: CrossAlign.center,

                children: [
                  Label(
                    text: 'You have pushed the button',
                    styleClass: "label-body",
                  ),
                  Label(text: 'this many times:', styleClass: "label-body"),
                  Label(text: '$_count', styleClass: "label-body"),
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
