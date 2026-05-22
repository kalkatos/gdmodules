class_name VisibilityAnimator3D
## 3D variant of VisibilityAnimator that handles fade transitions for an array of SpriteBase3D nodes.
extends Node3D

signal finished

@export var targets: Array[SpriteBase3D]
@export var target_alpha: float = 1.0
@export var start_active: bool
@export var deactivate_on_end: bool = true
@export var animation_time: float = 0.3

var is_showing: bool = false


## Initializes the 3D visibility animator, setting the initial alpha for all target sprites.
func _ready () -> void:
	var starting_alpha = target_alpha if start_active else 0.0
	# Synchronize all targets with the starting state
	for target in targets:
		is_showing = start_active
		target.modulate.a = starting_alpha
		target.visible = start_active


## Animates transparency for all target sprites to show or hide them in 3D space.
func animate_visibility (activate: bool):
	# Handle activation/fade-in
	if activate:
		if is_showing:
			return
		is_showing = true
		var tween_on = null
		for target in targets:
			target.modulate.a = 0.0
			target.visible = true
			tween_on = target.create_tween()
			tween_on.tween_property(target, "modulate:a", target_alpha, animation_time)
		await tween_on.finished
		finished.emit()
		return
	# Handle deactivation/fade-out
	if not is_showing:
		return
	is_showing = false
	var tween_off = null
	for target in targets:
		target.modulate.a = target_alpha
		tween_off = target.create_tween()
		tween_off.tween_property(target, "modulate:a", 0.0, animation_time)
	await tween_off.finished
	if deactivate_on_end:
		for target in targets:
			target.visible = false
	finished.emit()
