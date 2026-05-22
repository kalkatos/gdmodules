## Represents a pool of instances for a specific original node.
class_name Pool
extends RefCounted

var original_id: int
var prefab: Node
var available: Array[PoolItem]
var busy: Array[PoolItem]
var count: int


## Initializes a pool using the original node as a template.
func _init (original: Node) -> void:
	original_id = original.get_instance_id()
	prefab = original.duplicate()
	count = 1


## Returns an available node from the pool or creates a new one if necessary.
func get_new () -> Node:
	if available.size() == 0:
		return create_new()
	var item = null
	# Iterate backwards to find a valid pooled item
	for i in range(available.size() - 1, -1, -1):
		item = available[i]
		available.remove_at(i)
		if !item or !item.instance:
			continue
		break
	if item:
		busy.append(item)
	else:
		return create_new()
	return item.instance


## Internally instantiates a new node from the template and wraps it in a PoolItem.
func create_new () -> Node:
	var new_obj = prefab.duplicate()
	var new_item = PoolItem.new(new_obj, original_id)
	busy.append(new_item)
	count += 1
	new_item.number = count
	Pooler.add_child(new_obj)
	new_obj.owner = Pooler.get_tree().get_root()
	return new_obj
