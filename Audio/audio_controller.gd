## Central controller for managing background music (BGM) and sound effects (SFX) via dedicated channels and volume persistence.
extends AudioListener2D

@export var music_channel: AudioStreamPlayer2D
@export var sfx_channel_1: AudioStreamPlayer2D
@export var sfx_channel_2: AudioStreamPlayer2D
@export var sfx_channel_3: AudioStreamPlayer2D

var sfx_channels: Array[AudioStreamPlayer2D]
var channel_index: int = 0
var _master_music_volume: float = 1.0
var _master_sfx_volume: float = 1.0
var _has_loaded_volume: bool

var master_music_volume: float:
	get:
		return _master_music_volume
	set (value):
		SignalBus.emit_on_music_volume_set(value)

var master_sfx_volume: float:
	get:
		return _master_sfx_volume
	set (value):
		SignalBus.emit_on_sfx_volume_set(value)


## Initializes volume settings from storage and connects volume-related signals.
func _ready () -> void:
	# Load volume settings from local storage
	var saved_music_volume = Storage.load("master_music_volume", 1.0)
	print("Loaded music volume: " + str(saved_music_volume))
	var saved_sfx_volume = Storage.load("master_sfx_volume", 1.0)
	print("Loaded sfx volume: " + str(saved_sfx_volume))
	# Prepare SFX channel array for rotational playback
	sfx_channels = [
		sfx_channel_1,
		sfx_channel_2,
		sfx_channel_3, ]
	SignalBus._on_music_volume_set.connect(_handle_music_volume_set)
	SignalBus._on_sfx_volume_set.connect(_handle_sfx_volume_set)
	# Brief delay to ensure storage/signals are fully initialized before applying
	await get_tree().create_timer(0.1).timeout
	master_music_volume = saved_music_volume
	master_sfx_volume = saved_sfx_volume
	_has_loaded_volume = true


## Plays a sound effect using the next available SFX channel.
func play_sfx (sfx: AudioStream):
	while !_has_loaded_volume:
		await get_tree().process_frame
	if is_zero_approx(master_sfx_volume):
		return
	# Use circular buffer strategy to rotate through available channels
	var player = sfx_channels[channel_index]
	channel_index = (channel_index + 1) % sfx_channels.size()
	player.stream = sfx
	player.play(0)


## Plays music, checking if it is already playing.
func play_music (music: AudioStream):
	play_music_option(music, false)


## Plays music, forcing a restart even if it is already playing.
func play_music_force (music: AudioStream):
	play_music_option(music, true)


## Plays music with options for forcing a restart and handling fade transitions.
func play_music_option (music: AudioStream, force: bool):
	while not _has_loaded_volume:
		await get_tree().process_frame
	if is_zero_approx(master_music_volume):
		return
	# Stop currently playing music with a fade out if it's different or forced
	if music_channel.playing:
		if music_channel.stream == music and !force:
			return
		await create_tween().tween_property(music_channel, "volume_linear", 0, 0.5).finished
		music_channel.stop()
	music_channel.stream = music
	music_channel.play(0)
	# Fade in the new music track
	if music_channel.volume_linear < master_music_volume:
		create_tween().tween_property(music_channel, "volume_linear", master_music_volume, 0.5)


## Stops current music playback with a fade-out animation.
func stop_music ():
	if music_channel.playing:
		await create_tween().tween_property(music_channel, "volume_linear", 0, 0.5).finished
		music_channel.stop()


## Internal handler for music volume changes; persists setting to storage.
func _handle_music_volume_set (value: float):
	_master_music_volume = clamp(value, 0, 1)
	music_channel.volume_linear = _master_music_volume
	Storage.save("master_music_volume", _master_music_volume)


## Internal handler for SFX volume changes; persists setting to storage.
func _handle_sfx_volume_set (value: float):
	_master_sfx_volume = clamp(value, 0, 1)
	for channel in sfx_channels:
		channel.volume_linear = _master_sfx_volume
	Storage.save("master_sfx_volume", _master_sfx_volume)
