use raylib_sys::{
    CloseAudioDevice, GetMusicTimeLength, GetMusicTimePlayed, InitAudioDevice,
    IsAudioDeviceReady, IsMusicStreamPlaying, IsSoundPlaying, LoadMusicStream, LoadSound, Music,
    PauseMusicStream, PauseSound, PlayMusicStream, PlaySound, ResumeMusicStream, ResumeSound,
    SeekMusicStream, SetMasterVolume, SetMusicPan, SetMusicPitch, SetMusicVolume, SetSoundPan,
    SetSoundPitch, SetSoundVolume, Sound, StopMusicStream, StopSound, UnloadMusicStream,
    UnloadSound, UpdateMusicStream,
};
use std::collections::HashMap;
use std::os::raw::{c_char, c_float, c_int};
use std::sync::Mutex;

struct SoundWrapper(Sound);
unsafe impl Send for SoundWrapper {}
unsafe impl Sync for SoundWrapper {}

struct MusicWrapper(Music);
unsafe impl Send for MusicWrapper {}
unsafe impl Sync for MusicWrapper {}

static SOUNDS: Mutex<Option<HashMap<i32, SoundWrapper>>> = Mutex::new(None);
static MUSIC_STREAMS: Mutex<Option<HashMap<i32, MusicWrapper>>> = Mutex::new(None);
static mut NEXT_SOUND_ID: i32 = 1;
static mut NEXT_MUSIC_ID: i32 = 1;

fn with_sounds<F, R>(f: F) -> R
where
    F: FnOnce(&mut HashMap<i32, SoundWrapper>) -> R,
{
    let mut guard = SOUNDS.lock().unwrap();
    let map = guard.get_or_insert_with(HashMap::new);
    f(map)
}

fn with_music<F, R>(f: F) -> R
where
    F: FnOnce(&mut HashMap<i32, MusicWrapper>) -> R,
{
    let mut guard = MUSIC_STREAMS.lock().unwrap();
    let map = guard.get_or_insert_with(HashMap::new);
    f(map)
}

// ---------------------------------------------------------------------------
// Dispositivo de Audio Global
// ---------------------------------------------------------------------------

#[unsafe(no_mangle)]
pub extern "C" fn audio_init_device() -> c_int {
    unsafe {
        InitAudioDevice();
        if IsAudioDeviceReady() { 1 } else { 0 }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn audio_close_device() {
    unsafe {
        CloseAudioDevice();
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn audio_is_device_ready() -> c_int {
    unsafe {
        if IsAudioDeviceReady() { 1 } else { 0 }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn audio_set_master_volume(volume: c_float) {
    unsafe {
        SetMasterVolume(volume);
    }
}

// ---------------------------------------------------------------------------
// Efectos de Sonido (Sound)
// ---------------------------------------------------------------------------

#[unsafe(no_mangle)]
pub extern "C" fn sound_load(file_path: *const c_char) -> c_int {
    if file_path.is_null() {
        return 0;
    }
    unsafe {
        let sound = LoadSound(file_path);
        if sound.frameCount == 0 {
            return 0;
        }
        let id = NEXT_SOUND_ID;
        NEXT_SOUND_ID += 1;
        with_sounds(|map| {
            map.insert(id, SoundWrapper(sound));
        });
        id
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn sound_unload(id: c_int) {
    with_sounds(|map| {
        if let Some(sound) = map.remove(&id) {
            unsafe {
                UnloadSound(sound.0);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn sound_play(id: c_int) {
    with_sounds(|map| {
        if let Some(sound) = map.get(&id) {
            unsafe {
                PlaySound(sound.0);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn sound_stop(id: c_int) {
    with_sounds(|map| {
        if let Some(sound) = map.get(&id) {
            unsafe {
                StopSound(sound.0);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn sound_pause(id: c_int) {
    with_sounds(|map| {
        if let Some(sound) = map.get(&id) {
            unsafe {
                PauseSound(sound.0);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn sound_resume(id: c_int) {
    with_sounds(|map| {
        if let Some(sound) = map.get(&id) {
            unsafe {
                ResumeSound(sound.0);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn sound_is_playing(id: c_int) -> c_int {
    with_sounds(|map| {
        if let Some(sound) = map.get(&id) {
            unsafe {
                if IsSoundPlaying(sound.0) { 1 } else { 0 }
            }
        } else {
            0
        }
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn sound_set_volume(id: c_int, volume: c_float) {
    with_sounds(|map| {
        if let Some(sound) = map.get(&id) {
            unsafe {
                SetSoundVolume(sound.0, volume);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn sound_set_pitch(id: c_int, pitch: c_float) {
    with_sounds(|map| {
        if let Some(sound) = map.get(&id) {
            unsafe {
                SetSoundPitch(sound.0, pitch);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn sound_set_pan(id: c_int, pan: c_float) {
    with_sounds(|map| {
        if let Some(sound) = map.get(&id) {
            unsafe {
                SetSoundPan(sound.0, pan);
            }
        }
    });
}

// ---------------------------------------------------------------------------
// Música por Streaming (Music)
// ---------------------------------------------------------------------------

#[unsafe(no_mangle)]
pub extern "C" fn music_load(file_path: *const c_char) -> c_int {
    if file_path.is_null() {
        return 0;
    }
    unsafe {
        let music = LoadMusicStream(file_path);
        if music.frameCount == 0 {
            return 0;
        }
        let id = NEXT_MUSIC_ID;
        NEXT_MUSIC_ID += 1;
        with_music(|map| {
            map.insert(id, MusicWrapper(music));
        });
        id
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn music_unload(id: c_int) {
    with_music(|map| {
        if let Some(music) = map.remove(&id) {
            unsafe {
                UnloadMusicStream(music.0);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn music_play(id: c_int) {
    with_music(|map| {
        if let Some(music) = map.get(&id) {
            unsafe {
                PlayMusicStream(music.0);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn music_stop(id: c_int) {
    with_music(|map| {
        if let Some(music) = map.get(&id) {
            unsafe {
                StopMusicStream(music.0);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn music_pause(id: c_int) {
    with_music(|map| {
        if let Some(music) = map.get(&id) {
            unsafe {
                PauseMusicStream(music.0);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn music_resume(id: c_int) {
    with_music(|map| {
        if let Some(music) = map.get(&id) {
            unsafe {
                ResumeMusicStream(music.0);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn music_is_playing(id: c_int) -> c_int {
    with_music(|map| {
        if let Some(music) = map.get(&id) {
            unsafe {
                if IsMusicStreamPlaying(music.0) { 1 } else { 0 }
            }
        } else {
            0
        }
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn music_update(id: c_int) {
    with_music(|map| {
        if let Some(music) = map.get(&id) {
            unsafe {
                UpdateMusicStream(music.0);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn music_update_all() {
    with_music(|map| {
        for music in map.values() {
            unsafe {
                if IsMusicStreamPlaying(music.0) {
                    UpdateMusicStream(music.0);
                }
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn music_set_volume(id: c_int, volume: c_float) {
    with_music(|map| {
        if let Some(music) = map.get(&id) {
            unsafe {
                SetMusicVolume(music.0, volume);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn music_set_pitch(id: c_int, pitch: c_float) {
    with_music(|map| {
        if let Some(music) = map.get(&id) {
            unsafe {
                SetMusicPitch(music.0, pitch);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn music_set_pan(id: c_int, pan: c_float) {
    with_music(|map| {
        if let Some(music) = map.get(&id) {
            unsafe {
                SetMusicPan(music.0, pan);
            }
        }
    });
}

#[unsafe(no_mangle)]
pub extern "C" fn music_get_time_length(id: c_int) -> c_float {
    with_music(|map| {
        if let Some(music) = map.get(&id) {
            unsafe { GetMusicTimeLength(music.0) }
        } else {
            0.0
        }
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn music_get_time_played(id: c_int) -> c_float {
    with_music(|map| {
        if let Some(music) = map.get(&id) {
            unsafe { GetMusicTimePlayed(music.0) }
        } else {
            0.0
        }
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn music_seek(id: c_int, position: c_float) {
    with_music(|map| {
        if let Some(music) = map.get(&id) {
            unsafe {
                SeekMusicStream(music.0, position);
            }
        }
    });
}
