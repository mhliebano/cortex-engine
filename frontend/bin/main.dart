import 'package:frontend/core/application.dart';
import 'package:frontend/core/navigator.dart';

import 'app_styles.dart';
import 'views/test_view.dart';

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
  Navigator.registerRoutes({'test_view': () => TestView()});

  // Configurar la ruta de arranque inicial
  Navigator.initialRoute = 'test_view';

  // 3. Iniciar la aplicación
  await app.run();
}
