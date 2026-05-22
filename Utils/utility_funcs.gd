class_name Utils
## Collection of global static utility functions for common operations like raycasting, animations, and string checks.
extends Node

static var tween_map: Dictionary = {}


## Performs a bounce-like scale animation on a node, ensuring thread-safe tween management.
static func bounce_scale (node: Node, target_scale: Vector3, total_duration: float) -> Tween:
	# Kill existing scale tween for this node if it's currently running
	if tween_map.has(node):
		var tween_data = tween_map[node]
		var old_tween = tween_data[0]
		if old_tween and old_tween.is_valid():
			node.scale = tween_data[1]
			old_tween.kill()
		tween_map.erase(node)
	var starting_scale = node.scale
	var tween = node.create_tween()
	# Handle both 2D (Vector2) and 3D (Vector3) target scales
	if node is Node2D or node is Control:
		tween.tween_property(node, "scale", Vector2(target_scale.x, target_scale.y), total_duration / 2)
	else:
		tween.tween_property(node, "scale", target_scale, total_duration / 2)
	tween.tween_property(node, "scale", starting_scale, total_duration / 2)
	tween_map[node] = [tween, starting_scale]
	return tween


## Performs a 3D raycast from a starting point to an end point with a specific collision mask.
static func raycast (from: Vector3, to: Vector3, mask: int = 1) -> Dictionary:
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collision_mask = mask
	return Global.get_world_3d().direct_space_state.intersect_ray(query)


## Casts a ray from the mouse position and returns the first encountered instance of a specific type.
static func raycast_first_instance (mouse_pos: Vector2, type: Variant, exception: Node3D = null, mask: int = 1) -> Variant:
	var camera = Global.get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(mouse_pos)
	var ray = camera.project_ray_normal(mouse_pos)
	var to = from + ray * 100.0
	# Attempt multiple raycasts in case of overlapping colliders
	for i in range(5):
		var hit_info = raycast(from, to, mask)
		if hit_info:
			if hit_info.has("collider"):
				var collider = hit_info["collider"]
				if not collider:
					return null
				if is_instance_of(collider, type) and (not exception or collider != exception):
					return collider
			# If no match, continue ray from hit position
			from = hit_info["position"]
			to = from + ray * 100.0
	return null


## Checks if a string follows the conventional translation key format ($KEY_NAME$).
static func is_translation_key (text: String) -> bool:
	if text.is_empty():
		return false
	return text.begins_with("$") and text.ends_with("$")


## Animates a number in a Label or RichTextLabel from a starting value to an ending value.
## If [param discrete] is true, the value is rounded to the nearest integer and cast to int to avoid decimal suffixes.
static func animate_number (text_object: Node, start_value: float, end_value: float, duration: float = 0.5, discrete: bool = true) -> void:
	if not text_object is Label and not text_object is RichTextLabel:
		push_warning("animate_number: text_object is not a Label or RichTextLabel")
		return
	var was_interrupted: bool = false
	if tween_map.has(text_object):
		var old_tween = tween_map[text_object][0]
		if old_tween and old_tween.is_valid():
			old_tween.kill()
			was_interrupted = true
		tween_map.erase(text_object)
	text_object.set("text", str(int(round(start_value))) if discrete else str(start_value))
	if duration <= 0.0:
		text_object.set("text", str(int(round(end_value))) if discrete else str(end_value))
		return
	var hold_duration: float = min(duration, 0.06) if was_interrupted else 0.0
	var tween_duration: float = max(duration - hold_duration, 0.0)
	var tween = text_object.create_tween()
	tween_map[text_object] = [tween]
	if hold_duration > 0.0:
		tween.tween_interval(hold_duration)
	if tween_duration > 0.0:
		tween.tween_method(func (val: float) -> void: text_object.set("text", str(int(round(val))) if discrete else str(val)), start_value, end_value, tween_duration)
	else:
		tween.tween_callback(func () -> void: text_object.set("text", str(int(round(end_value))) if discrete else str(end_value)))
	tween.finished.connect(func () -> void: if tween_map.get(text_object, [null])[0] == tween: tween_map.erase(text_object))
