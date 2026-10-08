import 'package:frontend/core/application.dart';
import 'package:frontend/core/navigator.dart';
import 'package:frontend/core/utils.dart';

import 'app_styles.dart';
import 'views/example_view.dart';

void main() async {
  Debugger.showLayout = true;
  // 0. Inicializar Hoja de Estilos CSS Globales
  initAppStyles();

  // 1. Instanciar la aplicación
  final app = Application(
    title: 'Cortex Engine - Example-02',
    width: 800,
    height: 600,
  );

  // 2. Delegar la Tabla de Rutas diferidas (Lazy Loading) al Navigator
  Navigator.registerRoutes({'example_02': () => Example02()});

  // Configurar la ruta de arranque inicial
  Navigator.initialRoute = 'test_view';

  // 3. Iniciar la aplicación
  await app.run();
}
