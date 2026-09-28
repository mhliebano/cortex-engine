import 'package:ffi/ffi.dart';
import 'package:frontend/ffi/audio_bindings.dart';

/// Control global del dispositivo de audio en Cortex Engine.
class AudioEngine {
  static bool _initialized = false;

  /// Inicializa el dispositivo de audio nativo.
  static bool init() {
    if (_initialized) return isReady;
    final res = AudioBindings.audioInitDevice();
    _initialized = (res != 0);
    return _initialized;
  }

  /// Cierra y libera el dispositivo de audio nativo.
  static void close() {
    if (!_initialized) return;
    AudioBindings.audioCloseDevice();
    _initialized = false;
  }

  /// Retorna verdadero si el dispositivo de audio está listo.
  static bool get isReady => AudioBindings.audioIsDeviceReady() != 0;

  /// Ajusta el volumen maestro global del motor (0.0 a 1.0).
  static set masterVolume(double volume) {
    AudioBindings.audioSetMasterVolume(volume.clamp(0.0, 1.0));
  }

  /// Actualiza los buffers de todas las pistas de música en streaming activas.
  /// Se ejecuta automáticamente en el bucle principal de `Application`.
  static void updateMusic() {
    if (_initialized) {
      AudioBindings.musicUpdateAll();
    }
  }
}

/// Representa un efecto de sonido corto cargado en memoria RAM (WAV, MP3, OGG, etc.).
class Sound {
  final int id;
  final String path;
  bool _isDisposed = false;

  Sound._(this.id, this.path);

  /// Carga un archivo de sonido desde el disco. Retorna `null` si no se pudo cargar.
  static Sound? load(String filePath) {
    if (!AudioEngine._initialized) {
      AudioEngine.init();
    }
    final pathPtr = filePath.toNativeUtf8();
    try {
      final id = AudioBindings.soundLoad(pathPtr);
      if (id <= 0) return null;
      return Sound._(id, filePath);
    } finally {
      calloc.free(pathPtr);
    }
  }

  /// Reproduce el efecto de sonido.
  void play() {
    if (_isDisposed) return;
    AudioBindings.soundPlay(id);
  }

  /// Detiene la reproducción del sonido.
  void stop() {
    if (_isDisposed) return;
    AudioBindings.soundStop(id);
  }

  /// Pausa la reproducción del sonido.
  void pause() {
    if (_isDisposed) return;
    AudioBindings.soundPause(id);
  }

  /// Reanuda la reproducción pausada del sonido.
  void resume() {
    if (_isDisposed) return;
    AudioBindings.soundResume(id);
  }

  /// Indica si el sonido está reproduciéndose en este momento.
  bool get isPlaying {
    if (_isDisposed) return false;
    return AudioBindings.soundIsPlaying(id) != 0;
  }

  /// Configura el volumen del sonido (0.0 a 1.0).
  set volume(double value) {
    if (_isDisposed) return;
    AudioBindings.soundSetVolume(id, value.clamp(0.0, 1.0));
  }

  /// Configura el pitch/velocidad de reproducción del sonido (1.0 es normal).
  set pitch(double value) {
    if (_isDisposed) return;
    AudioBindings.soundSetPitch(id, value);
  }

  /// Configura el balance/panorámica estéreo (0.0 izquierda, 0.5 centro, 1.0 derecha).
  set pan(double value) {
    if (_isDisposed) return;
    AudioBindings.soundSetPan(id, value.clamp(0.0, 1.0));
  }

  /// Libera los recursos nativos del sonido.
  void dispose() {
    if (_isDisposed) return;
    AudioBindings.soundUnload(id);
    _isDisposed = true;
  }
}

/// Representa una pista de música de larga duración reproducida mediante streaming desde disco.
class Music {
  final int id;
  final String path;
  bool _isDisposed = false;

  Music._(this.id, this.path);

  /// Carga un archivo de música para streaming. Retorna `null` si falla.
  static Music? load(String filePath) {
    if (!AudioEngine._initialized) {
      AudioEngine.init();
    }
    final pathPtr = filePath.toNativeUtf8();
    try {
      final id = AudioBindings.musicLoad(pathPtr);
      if (id <= 0) return null;
      return Music._(id, filePath);
    } finally {
      calloc.free(pathPtr);
    }
  }

  /// Inicia la reproducción de la música.
  void play() {
    if (_isDisposed) return;
    AudioBindings.musicPlay(id);
  }

  /// Detiene la música y reinicia su posición.
  void stop() {
    if (_isDisposed) return;
    AudioBindings.musicStop(id);
  }

  /// Pausa la reproducción de la música.
  void pause() {
    if (_isDisposed) return;
    AudioBindings.musicPause(id);
  }

  /// Reanuda la reproducción pausada.
  void resume() {
    if (_isDisposed) return;
    AudioBindings.musicResume(id);
  }

  /// Indica si la música está reproduciéndose en este momento.
  bool get isPlaying {
    if (_isDisposed) return false;
    return AudioBindings.musicIsPlaying(id) != 0;
  }

  /// Procesa manualmente el buffer de streaming si es necesario.
  void update() {
    if (_isDisposed) return;
    AudioBindings.musicUpdate(id);
  }

  /// Configura el volumen de la música (0.0 a 1.0).
  set volume(double value) {
    if (_isDisposed) return;
    AudioBindings.musicSetVolume(id, value.clamp(0.0, 1.0));
  }

  /// Configura el pitch/velocidad de reproducción de la música.
  set pitch(double value) {
    if (_isDisposed) return;
    AudioBindings.musicSetPitch(id, value);
  }

  /// Configura el balance estéreo (0.0 izquierda, 0.5 centro, 1.0 derecha).
  set pan(double value) {
    if (_isDisposed) return;
    AudioBindings.musicSetPan(id, value.clamp(0.0, 1.0));
  }

  /// Duración total de la pista de música en segundos.
  double get duration {
    if (_isDisposed) return 0.0;
    return AudioBindings.musicGetTimeLength(id);
  }

  /// Tiempo de reproducción actual en segundos.
  double get timePlayed {
    if (_isDisposed) return 0.0;
    return AudioBindings.musicGetTimePlayed(id);
  }

  /// Salta a una posición específica de tiempo en segundos.
  void seek(double positionInSeconds) {
    if (_isDisposed) return;
    AudioBindings.musicSeek(id, positionInSeconds);
  }

  /// Libera los recursos nativos de la pista de música.
  void dispose() {
    if (_isDisposed) return;
    AudioBindings.musicUnload(id);
    _isDisposed = true;
  }
}
