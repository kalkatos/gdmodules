class_name StorageBinder
## Component that binds a specific storage key to signals, enabling reactive updates when storage changes.
extends Node

signal on_value_changed (value: Variant)

@export var key: String


## Connects to storage signals and emits the initial value if it exists.
func _ready () -> void:
	Storage.on_value_saved.connect(_handle_value_changed)
	if Storage.has_value(key):
		on_value_changed.emit(Storage.saved_dict[key])


## Disconnects from storage signals when leaving the scene tree.
func _exit_tree () -> void:
	Storage.on_value_saved.disconnect(_handle_value_changed)


## Requests a value change via the central Storage manager.
func change_value (value: Variant):
	Storage.save(key, value)


## Internal handler triggered on any storage value save; filters by the associated key.
func _handle_value_changed (key_: String, value: Variant):
	if key_ != key:
		return
	on_value_changed.emit(value)
