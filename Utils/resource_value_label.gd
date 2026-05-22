class_name ResourceValueLabel
## Helper component that automatically updates a target node's text with a property value from a Resource.
extends Node

@export var target: Node
@export var resource: Resource
@export var property_name: String = ""
@export var prefix: String = ""
@export var suffix: String = ""


## Validates the setup and updates the target node's text with the resource property's value.
func setup () -> void:
	if not target or not resource or property_name == "":
		return
	# Ensure the target node can receive text updates
	if not target.has_method("set_text"):
		push_warning("Target node does not have set_text method")
		return
	if property_name == "":
		push_warning("Property name is empty")
		return
	# Verify that the resource actually contains the specified property
	if not resource.get_property_list().any(func(p): return p.name == property_name):
		push_warning("Resource does not have property: %s" % property_name)
		return
	var value = resource.get(property_name)
	target.set_text("%s%s%s" % [prefix, str(value), suffix])
