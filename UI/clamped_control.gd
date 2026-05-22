## Control implementation that allows setting its position clamped to the screen bounds.
class_name ClampedControl
extends Control

@export var target: Control

var offset_from_ratio: Vector2:
	get:
		if !target:
			target = self
		return -Vector2(target.size.x * target.pivot_offset_ratio.x, target.size.y * target.pivot_offset_ratio.y)


## Applies a position to the target control while accounting for pivot ratio offsets.
func set_position_offset (new_position: Vector2):
	if not target:
		target = self
	target.position = new_position + offset_from_ratio


func must_clamp (new_position: Vector2) -> bool:
	if not target:
		target = self
	var target_pos = get_position_screen_clamped(new_position)
	return not target_pos.is_equal_approx(new_position)


## Clamps the given position to screen bounds and applies it to the target control.
func set_position_screen_clamped (new_position: Vector2):
	new_position = get_position_screen_clamped(new_position)
	set_position_offset(new_position)


## Calculates a screen-clamped version of the provided position based on the target's size and pivot.
func get_position_screen_clamped (new_position: Vector2) -> Vector2:
	if not target:
		target = self
	var screen_size = get_window().content_scale_size
	new_position.x = clamp(new_position.x, target.size.x * target.pivot_offset_ratio.x, screen_size.x - target.size.x * (1 - target.pivot_offset_ratio.x))
	new_position.y = clamp(new_position.y, target.size.y * target.pivot_offset_ratio.y, screen_size.y - target.size.y * (1 - target.pivot_offset_ratio.y))
	return new_position
