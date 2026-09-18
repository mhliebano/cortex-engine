import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'lib_loader.dart';

// ---------------------------------------------------------------------------
// Firmas FFI - Dispositivo Global
// ---------------------------------------------------------------------------
typedef AudioInitDeviceC = ffi.Int32 Function();
typedef AudioCloseDeviceC = ffi.Void Function();
typedef AudioIsDeviceReadyC = ffi.Int32 Function();
typedef AudioSetMasterVolumeC = ffi.Void Function(ffi.Float);

typedef AudioInitDevice = int Function();
typedef AudioCloseDevice = void Function();
typedef AudioIsDeviceReady = int Function();
typedef AudioSetMasterVolume = void Function(double);

// ---------------------------------------------------------------------------
// Firmas FFI - Efectos de Sonido (Sound)
// ---------------------------------------------------------------------------
typedef SoundLoadC = ffi.Int32 Function(ffi.Pointer<Utf8>);
typedef SoundUnloadC = ffi.Void Function(ffi.Int32);
typedef SoundPlayC = ffi.Void Function(ffi.Int32);
typedef SoundStopC = ffi.Void Function(ffi.Int32);
typedef SoundPauseC = ffi.Void Function(ffi.Int32);
typedef SoundResumeC = ffi.Void Function(ffi.Int32);
typedef SoundIsPlayingC = ffi.Int32 Function(ffi.Int32);
typedef SoundSetVolumeC = ffi.Void Function(ffi.Int32, ffi.Float);
typedef SoundSetPitchC = ffi.Void Function(ffi.Int32, ffi.Float);
typedef SoundSetPanC = ffi.Void Function(ffi.Int32, ffi.Float);

typedef SoundLoad = int Function(ffi.Pointer<Utf8>);
typedef SoundUnload = void Function(int);
typedef SoundPlay = void Function(int);
typedef SoundStop = void Function(int);
typedef SoundPause = void Function(int);
typedef SoundResume = void Function(int);
typedef SoundIsPlaying = int Function(int);
typedef SoundSetVolume = void Function(int, double);
typedef SoundSetPitch = void Function(int, double);
typedef SoundSetPan = void Function(int, double);

// ---------------------------------------------------------------------------
// Firmas FFI - Música por Streaming (Music)
// ---------------------------------------------------------------------------
typedef MusicLoadC = ffi.Int32 Function(ffi.Pointer<Utf8>);
typedef MusicUnloadC = ffi.Void Function(ffi.Int32);
typedef MusicPlayC = ffi.Void Function(ffi.Int32);
typedef MusicStopC = ffi.Void Function(ffi.Int32);
typedef MusicPauseC = ffi.Void Function(ffi.Int32);
typedef MusicResumeC = ffi.Void Function(ffi.Int32);
typedef MusicIsPlayingC = ffi.Int32 Function(ffi.Int32);
typedef MusicUpdateC = ffi.Void Function(ffi.Int32);
typedef MusicUpdateAllC = ffi.Void Function();
typedef MusicSetVolumeC = ffi.Void Function(ffi.Int32, ffi.Float);
typedef MusicSetPitchC = ffi.Void Function(ffi.Int32, ffi.Float);
typedef MusicSetPanC = ffi.Void Function(ffi.Int32, ffi.Float);
typedef MusicGetTimeLengthC = ffi.Float Function(ffi.Int32);
typedef MusicGetTimePlayedC = ffi.Float Function(ffi.Int32);
typedef MusicSeekC = ffi.Void Function(ffi.Int32, ffi.Float);

typedef MusicLoad = int Function(ffi.Pointer<Utf8>);
typedef MusicUnload = void Function(int);
typedef MusicPlay = void Function(int);
typedef MusicStop = void Function(int);
typedef MusicPause = void Function(int);
typedef MusicResume = void Function(int);
typedef MusicIsPlaying = int Function(int);
typedef MusicUpdate = void Function(int);
typedef MusicUpdateAll = void Function();
typedef MusicSetVolume = void Function(int, double);
typedef MusicSetPitch = void Function(int, double);
typedef MusicSetPan = void Function(int, double);
typedef MusicGetTimeLength = double Function(int);
typedef MusicGetTimePlayed = double Function(int);
typedef MusicSeek = void Function(int, double);

// ---------------------------------------------------------------------------
// Carga perezosa de funciones nativas desde la librería compartida
// ---------------------------------------------------------------------------
class AudioBindings {
  static final ffi.DynamicLibrary _lib = loadNativeLibrary();

  // Dispositivo
  static final AudioInitDevice audioInitDevice =
      _lib.lookupFunction<AudioInitDeviceC, AudioInitDevice>('audio_init_device');
  static final AudioCloseDevice audioCloseDevice =
      _lib.lookupFunction<AudioCloseDeviceC, AudioCloseDevice>('audio_close_device');
  static final AudioIsDeviceReady audioIsDeviceReady =
      _lib.lookupFunction<AudioIsDeviceReadyC, AudioIsDeviceReady>('audio_is_device_ready');
  static final AudioSetMasterVolume audioSetMasterVolume =
      _lib.lookupFunction<AudioSetMasterVolumeC, AudioSetMasterVolume>('audio_set_master_volume');

  // Sound
  static final SoundLoad soundLoad =
      _lib.lookupFunction<SoundLoadC, SoundLoad>('sound_load');
  static final SoundUnload soundUnload =
      _lib.lookupFunction<SoundUnloadC, SoundUnload>('sound_unload');
  static final SoundPlay soundPlay =
      _lib.lookupFunction<SoundPlayC, SoundPlay>('sound_play');
  static final SoundStop soundStop =
      _lib.lookupFunction<SoundStopC, SoundStop>('sound_stop');
  static final SoundPause soundPause =
      _lib.lookupFunction<SoundPauseC, SoundPause>('sound_pause');
  static final SoundResume soundResume =
      _lib.lookupFunction<SoundResumeC, SoundResume>('sound_resume');
  static final SoundIsPlaying soundIsPlaying =
      _lib.lookupFunction<SoundIsPlayingC, SoundIsPlaying>('sound_is_playing');
  static final SoundSetVolume soundSetVolume =
      _lib.lookupFunction<SoundSetVolumeC, SoundSetVolume>('sound_set_volume');
  static final SoundSetPitch soundSetPitch =
      _lib.lookupFunction<SoundSetPitchC, SoundSetPitch>('sound_set_pitch');
  static final SoundSetPan soundSetPan =
      _lib.lookupFunction<SoundSetPanC, SoundSetPan>('sound_set_pan');

  // Music
  static final MusicLoad musicLoad =
      _lib.lookupFunction<MusicLoadC, MusicLoad>('music_load');
  static final MusicUnload musicUnload =
      _lib.lookupFunction<MusicUnloadC, MusicUnload>('music_unload');
  static final MusicPlay musicPlay =
      _lib.lookupFunction<MusicPlayC, MusicPlay>('music_play');
  static final MusicStop musicStop =
      _lib.lookupFunction<MusicStopC, MusicStop>('music_stop');
  static final MusicPause musicPause =
      _lib.lookupFunction<MusicPauseC, MusicPause>('music_pause');
  static final MusicResume musicResume =
      _lib.lookupFunction<MusicResumeC, MusicResume>('music_resume');
  static final MusicIsPlaying musicIsPlaying =
      _lib.lookupFunction<MusicIsPlayingC, MusicIsPlaying>('music_is_playing');
  static final MusicUpdate musicUpdate =
      _lib.lookupFunction<MusicUpdateC, MusicUpdate>('music_update');
  static final MusicUpdateAll musicUpdateAll =
      _lib.lookupFunction<MusicUpdateAllC, MusicUpdateAll>('music_update_all');
  static final MusicSetVolume musicSetVolume =
      _lib.lookupFunction<MusicSetVolumeC, MusicSetVolume>('music_set_volume');
  static final MusicSetPitch musicSetPitch =
      _lib.lookupFunction<MusicSetPitchC, MusicSetPitch>('music_set_pitch');
  static final MusicSetPan musicSetPan =
      _lib.lookupFunction<MusicSetPanC, MusicSetPan>('music_set_pan');
  static final MusicGetTimeLength musicGetTimeLength =
      _lib.lookupFunction<MusicGetTimeLengthC, MusicGetTimeLength>('music_get_time_length');
  static final MusicGetTimePlayed musicGetTimePlayed =
      _lib.lookupFunction<MusicGetTimePlayedC, MusicGetTimePlayed>('music_get_time_played');
  static final MusicSeek musicSeek =
      _lib.lookupFunction<MusicSeekC, MusicSeek>('music_seek');
}
