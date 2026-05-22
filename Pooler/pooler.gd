extends Node
## Global utility for object pooling, supporting Node2D, Node3D, and Control nodes.
## Automatically manages object lifecycle based on visibility changes.

var _pool_container: Dictionary[int, Pool] = {}
var _prefab_mapping: Dictionary[PackedScene, Node] = {}


## Notifies the pooler that an item has finished its task and is available for reuse.
func notify_finished (item: PoolItem) -> void:
	var id = item.original_id
	if !_pool_container.has(id):
		push_error("Something went wrong, pool container does not have id: " + str(id))
		return
	var pool = _pool_container[id]
	var index = pool.busy.find(item)
	if index < 0:
		push_error("Something went wrong, item is not in busy list")
	else:
		pool.busy.remove_at(index)
	# Insert at the beginning for Most Recently Used strategy
	pool.available.insert(0, item)


## Retrieves a new or recycled instance of the provided original node.
func get_new (original: Node) -> Node:
	var id = original.get_instance_id()
	if !_pool_container.has(id):
		_pool_container[id] = Pool.new(original)
	var other = _pool_container[id].get_new()
	return other


func get_new_from_prefab (prefab: PackedScene) -> Node:
	var instance = _prefab_mapping.get(prefab, null)
	if not instance:
		instance = prefab.instantiate()
		add_child(instance)
		instance.owner = get_tree().get_root()
		_prefab_mapping[prefab] = instance
	var result = get_new(instance)
	instance.visible = false
	return result
