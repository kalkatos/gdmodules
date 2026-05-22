## Centralized persistence manager for saving and loading game data to local storage using JSON serialization.
extends Node

signal on_value_saved (key: String, value: Variant)

const SAVE_NAME: String = "save_game"

var saved_dict := {}
var save_name: String = "user://%s.data" % SAVE_NAME


## Loads and parses the save file into the internal dictionary upon entering the scene tree.
func _enter_tree () -> void:
	var serialized = load_from_file()
	if serialized.is_empty():
		saved_dict = {}
	else:
		# Deserialize JSON content into the runtime dictionary
		saved_dict = JSON.parse_string(serialized) as Dictionary


## Saves a value associated with a key to local storage.
func save (key: String, value: Variant):
	saved_dict[key] = value
	# Serialize the entire dictionary and persist to file
	save_to_file(JSON.stringify(saved_dict))
	on_value_saved.emit(key, value)


## Retrieves a value from storage, returning a default if the key is missing.
func load (key: String, default_value: Variant) -> Variant:
	if not has_value(key):
		return default_value
	return saved_dict[key]


## Checks if a key exists in the current storage dictionary.
func has_value (key: String) -> bool:
	return saved_dict.has(key)


## Internal helper to write a string directly to the designated save file.
func save_to_file (content: String):
	var file = FileAccess.open(save_name, FileAccess.WRITE)
	file.store_string(content)


## Internal helper to read the entire content of the save file.
func load_from_file () -> String:
	var file = FileAccess.open(save_name, FileAccess.READ)
	if not file:
		return "";
	var content = file.get_as_text()
	return content
