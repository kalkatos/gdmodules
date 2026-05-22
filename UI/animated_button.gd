class_name AnimatedButton
extends BaseButton


@export var hover_scale := Vector2(1.025, 1.025)
@export var press_scale := Vector2(0.975, 0.975)
@export var normal_scale := Vector2(1.0, 1.0)
@export var disabled_color := Color(0.7, 0.7, 0.7, 1.0)
@export var highlighted_color := Color(1.15, 1.15, 1.15, 1.0)
@export var tween_duration := 0.1

var current_tween: Tween = null


func _ready () -> void:
	pivot_offset_ratio = Vector2(0.5, 0.5)
	mouse_entered.connect(_handle_mouse_entered)
	mouse_exited.connect(_handle_mouse_exited)
	button_down.connect(_handle_button_down)
	button_up.connect(_handle_button_up)
	scale = normal_scale


func _set (property: StringName, value: Variant) -> bool:
	if property == "disabled":
		disabled = value
		if disabled:
			_tween_to(normal_scale)
			modulate = disabled_color
		else:
			_tween_to(normal_scale)
			modulate = Color.WHITE
		return true
	return false


func _handle_mouse_entered () -> void:
	if disabled:
		return
	_tween_to(hover_scale)
	modulate = highlighted_color
	z_index += 1


func _handle_mouse_exited () -> void:
	if button_pressed:
		_tween_to(press_scale)
	else:
		_tween_to(normal_scale)
	if disabled:
		return
	modulate = Color.WHITE
	z_index -= 1


func _handle_button_down () -> void:
	if disabled:
		return
	_tween_to(press_scale)


func _handle_button_up () -> void:
	if is_hovered():
		_tween_to(hover_scale)
	else:
		_tween_to(normal_scale)


func _tween_to (target_scale: Vector2) -> void:
	if current_tween:
		current_tween.kill()
	current_tween = create_tween()
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.set_trans(Tween.TRANS_BACK)
	current_tween.tween_property(self, "scale", target_scale, tween_duration)
