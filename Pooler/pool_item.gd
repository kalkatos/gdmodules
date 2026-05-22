## Wrapper for an individual instance within a pool, tracking its lifecycle.
class_name PoolItem
extends RefCounted

var instance: Node
var original_id: int
var number: int


## Connects to the instance's visibility signal to automatically handle recycling.
func _init (_instance: Node, _id: int) -> void:
	instance = _instance
	original_id = _id
	instance.visibility_changed.connect(_handle_visibility_changed)


## Internal handler triggered when an instance is hidden, signalling it's ready for recycling.
func _handle_visibility_changed () -> void:
	if !instance.visible:
		Pooler.notify_finished(self)
