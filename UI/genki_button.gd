class_name GenkiButton
extends AnimatedButton

@export var click_sfx: AudioStream
@export var tooltip: String


func _handle_mouse_entered () -> void:
	super()
	if not tooltip.is_empty():
		SignalBus.emit_show_tooltip(tooltip)


func _handle_mouse_exited () -> void:
	super()
	SignalBus.emit_hide_tooltip()


func _pressed () -> void:
	AudioController.play_sfx(click_sfx)
