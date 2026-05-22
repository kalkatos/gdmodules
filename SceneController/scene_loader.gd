class_name SceneLoader
## Simple utility component to trigger scene transitions to a pre-defined TPCN file.
extends Node

@export_file("*.tscn") var scene: String


## Changes the current scene to the one specified in the 'scene' export property.
func load_scene () -> void:
	if !scene:
		push_error("No scene provided.")
		return
	get_tree().change_scene_to_file(scene)
