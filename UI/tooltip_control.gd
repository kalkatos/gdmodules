## ClampedControl implementation for a tooltip, with open/close animations.
class_name TooltipControl
extends ClampedControl

var _main_tween: Tween
var _is_open: bool = false
var _is_closing: bool = false


## Initializes the tooltip by hiding the background panel.
func _ready () -> void:
	target.visible = false


## Starts the tooltip's open animation, scaling up and fading in content.
func open () -> void:
	_is_closing = false
	_is_open = true
	target.visible = true
	target.reset_size()
	# Reset state for animation
	target.modulate.a = 0.0
	if _main_tween and _main_tween.is_valid():
		_main_tween.kill()
	_main_tween = create_tween()
	# Scale animation for the background and fade for the content
	_main_tween.tween_property(target, "modulate:a", 1.0, 0.2)


## Starts the tooltip's close animation, fading out the entire panel.
func close () -> void:
	_is_open = false
	_is_closing = true
	target.modulate.a = 1.0
	if _main_tween and _main_tween.is_valid():
		_main_tween.kill()
	_main_tween = create_tween()
	_main_tween.tween_property(target, "modulate:a", 0.0, 0.2)
	await _main_tween.finished
	_is_closing = false
	# Check if still closing state after animation
	if _is_open:
		return
	target.visible = false
