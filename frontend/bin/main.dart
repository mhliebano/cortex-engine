import 'package:cortex/engine/application.dart';
import 'package:cortex/engine/navigator.dart';
import 'app_styles.dart';

import 'views/elements_ui_example.dart';

void main() async {
  // 0. Inicializar Hoja de Estilos CSS Globales
  initAppStyles();

  // 1. Instanciar la aplicación
  final app = Application(
    title: 'Cortex Engine Studio - Clases de Vista Orientadas a Objetos',
    width: 800,
    height: 600,
  );

  // 2. Delegar la Tabla de Rutas diferidas (Lazy Loading) al Navigator
  Navigator.registerRoutes({'elements_ui_example': () => ElementsUiExample()});

  // Configurar la ruta de arranque inicial
  Navigator.initialRoute = 'elements_ui_example';

  // 3. Iniciar la aplicación
  await app.run();
}
