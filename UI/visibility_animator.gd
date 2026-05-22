class_name VisibilityAnimator
## Component that handles smooth fade transitions for Control nodes based on visibility changes.
extends Control

signal finished

@export var target: Control
@export var start_active: bool
@export var deactivate_on_end: bool = true
@export var animation_time: float = 0.3

var is_showing: bool = false


## Initializes state, ensuring the target node's visibility matches the starting configuration.
func _ready () -> void:
	if target != self and not target.is_node_ready():
		await target.ready
	target.visible = start_active
	is_showing = target.visible and not is_zero_approx(target.modulate.a)

## Animates the target's opacity to show or hide it.
func animate_visibility (active: bool):
	# Handle fade-in transition
	if active:
		if is_showing:
			return
		is_showing = true
		target.modulate.a = 0.0
		target.visible = true
		var tween_on = create_tween()
		tween_on.tween_property(target, "modulate:a", 1.0, animation_time)
		await tween_on.finished
		finished.emit()
		return
	# Handle fade-out transition
	if not is_showing:
		return
	is_showing = false
	target.modulate.a = 1.0
	var tween_off = create_tween()
	# Animate transparency to zero
	tween_off.tween_property(target, "modulate:a", 0.0, animation_time)
	await tween_off.finished
	finished.emit()
	if deactivate_on_end:
		target.visible = false
