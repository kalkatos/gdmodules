class_name AudioPlayer
## Helper component to trigger audio playback from any node in the scene tree.
extends Node

@export var audio: AudioStream


## Triggers the assigned audio stream as a global SFX.
func play_global_sfx ():
	AudioController.play_sfx(audio)


## Triggers the assigned audio stream as global music.
func play_global_music (force: bool = false):
	AudioController.play_music_option(audio, force)


## Stops the currently playing global music.
func stop_music ():
	AudioController.stop_music()
