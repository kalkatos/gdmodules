## Sample script to demonstrate and test screen-clamped UI positioning on mouse click.
extends Control

@export var control: TooltipControl

var is_open: bool


## Listens for click events to reposition and toggle the test tooltip.
func _input (event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if not is_open:
			print("Opening")
			control.set_position_screen_clamped(event.position)
			control.open()
			is_open = true
		else:
			control.close()
			is_open = false
