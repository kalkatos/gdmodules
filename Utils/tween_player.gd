class_name TweenPlayer
## High-level component to trigger predefined tween animations (bump, shake) on a target node.
extends Node

@export_subgroup("General")
@export var target: Node
@export var duration: float = 0.2
@export var animation: TweenAnimation
@export var ease_: Tween.EaseType = Tween.EASE_IN_OUT
@export var transition: Tween.TransitionType = Tween.TRANS_LINEAR
@export var is_relative: bool = true
@export_subgroup("Bump Settings")
@export var bump_magnitude: float = 1.1
@export var override_pivot_offset: Vector2 = Vector2(0.5, 0.5)
@export_subgroup("Rotation Settings")
@export var rotation_axis: Vector3 = Vector3(0, 0, 1)
@export var rotation_angle: float = 90
@export_subgroup("Translate Settings")
@export var translate_target: Vector3 = Vector3(0, 0, 0)

var _starting_position: Vector3
var _starting_rotation: Vector3
var _starting_scale: Vector3
var _tween: Tween

enum TweenAnimation
{
	NONE,
	BUMP,
	TRANSLATE,
	ROTATE,
}


func _enter_tree() -> void:
	_set_starting_state()


func _set_starting_state () -> void:
	if not target:
		return
	_starting_position = target.position if target.position is Vector3 else Vector3(target.position.x, target.position.y, 0.0)
	_starting_rotation = target.rotation_degrees if target.rotation_degrees is Vector3 else Vector3(0, 0, target.rotation_degrees)
	_starting_scale = target.scale if target.scale is Vector3 else Vector3(target.scale.x, target.scale.y, 0.0)


func _reset () -> void:
	if not target:
		return
	if target is Node3D:
		target.position = _starting_position
		target.rotation_degrees = _starting_rotation
		target.scale = _starting_scale
	elif target is CanvasItem:
		target.position = Vector2(_starting_position.x, _starting_position.y)
		target.rotation_degrees = _starting_rotation.z
		target.scale = Vector2(_starting_scale.x, _starting_scale.y)


## Plays the designated tween animation on the target node.
func play (kill_current: bool = true) -> Tween:
	if not target or animation == TweenAnimation.NONE:
		return null
	if _tween and _tween.is_valid() and kill_current:
		kill()
	# Automatically calculate pivot offset for Control nodes
	_reset()
	if target is Control:
		var control = target as Control
		control.pivot_offset_ratio = override_pivot_offset
	match animation:
		TweenAnimation.BUMP:
			_tween = Utils.bounce_scale(target, Vector3.ONE * bump_magnitude, duration)
			_tween.set_trans(transition)
			_tween.set_ease(ease_)
			return _tween
		TweenAnimation.TRANSLATE:
			_tween = create_tween()
			var target_position = target.position + (translate_target if is_relative else translate_target)
			_tween.tween_property(target, "position", target_position, duration)
			_tween.set_trans(transition)
			_tween.set_ease(ease_)
			return _tween
		TweenAnimation.ROTATE:
			_tween = create_tween()
			var target_rotation = target.rotation_degrees + (rotation_axis * rotation_angle if is_relative else rotation_axis * rotation_angle)
			_tween.tween_property(target, "rotation_degrees", target_rotation, duration)
			_tween.set_trans(transition)
			_tween.set_ease(ease_)
			return _tween
	return null


func kill () -> void:
	# Resets the target node to its original state if reset_on_end is true
	if not target:
		return
	if _tween:
		_tween.kill()
		_tween = null
