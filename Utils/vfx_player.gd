class_name VFXPlayer
## Utility class for instantiating and playing visual effects (particles, animations) in the game
extends Node

static var first_instances: Dictionary[PackedScene, Node] = {}


static func _emit_3d (vfx: Node, position: Vector3) -> void:
	vfx.global_position = position
	vfx.emitting = true


static func _emit_2d (vfx: Node, position: Vector2) -> void:
	vfx.global_position = position
	vfx.emitting = true


static func play_3d (prefab: PackedScene, position: Vector3, parent: Node = null) -> Node:
	var instance: Node
	if first_instances.has(prefab) and is_instance_valid(first_instances[prefab]):
		instance = first_instances[prefab]
		if not instance.emitting:
			_emit_3d(instance, position)
			return instance
		# If the instance is still active, spawn a new one from the pool to handle overlapping effects
		var other = Pooler.get_new(instance) as Node
		if not parent:
			parent = instance.get_parent()
		if other.get_parent() != parent:
			parent.add_child(other)
			other.owner = parent
		_emit_3d(other, position)
		return other
	# Instantiate first occurrence or if the previous instance was freed
	instance = prefab.instantiate()
	if parent:
		parent.add_child(instance)
		instance.owner = parent
	else:
		Global.get_tree().get_root().add_child(instance)
		instance.owner = Global.get_tree().get_root()
	first_instances[prefab] = instance
	_emit_3d(instance, position)
	return instance


static func play_2d (prefab: PackedScene, position: Vector2, parent: Node = null) -> Node:
	var instance: Node
	if first_instances.has(prefab) and is_instance_valid(first_instances[prefab]):
		instance = first_instances[prefab]
		if not instance.emitting:
			_emit_2d(instance, position)
			return instance
		# If the instance is still active, spawn a new one from the pool to handle overlapping effects
		var other = Pooler.get_new(instance) as Node
		if not parent:
			parent = instance.get_parent()
		if other.get_parent() != parent:
			parent.add_child(other)
			other.owner = parent
		_emit_2d(other, position)
		return other
	# Instantiate first occurrence or if the previous instance was freed
	instance = prefab.instantiate()
	if parent:
		parent.add_child(instance)
		instance.owner = parent
	else:
		Global.get_tree().get_root().add_child(instance)
		instance.owner = Global.get_tree().get_root()
	first_instances[prefab] = instance
	_emit_2d(instance, position)
	return instance


static func play_and_move_2d (prefab: PackedScene, from: Vector2, to: Vector2, duration: float, parent: Node = null) -> Tween:
	var vfx_instance = play_2d(prefab, from, parent)
	var tween: Tween = vfx_instance.create_tween()
	tween.tween_interval(0.2)
	tween.tween_property(vfx_instance, "global_position", to, duration)
	tween.tween_interval(0.1)
	tween.tween_callback(func (): vfx_instance.emitting = false)
	return tween
