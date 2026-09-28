/// Concentrador central de herramientas de depuración del motor Cortex.
abstract class Debugger {
  /// Activa o desactiva la visualización del depurador visual de layout.
  static bool showLayout = true;
  static void debugPrint(String message) {
    print("******************************************");
    print('[CORTEX] $message');
    print("******************************************");
  }
}
