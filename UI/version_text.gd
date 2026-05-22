## Automatically updates the label text with the current application version from ProjectSettings.
extends Label


## Retrieves and displays the version string on initialization.
func _ready () -> void:
	set_text(ProjectSettings.get_setting("application/config/version"))
