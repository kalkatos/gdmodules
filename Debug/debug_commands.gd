@tool
## In-game debug console that allows executing custom commands and viewing logs.
extends CanvasLayer

@export var disable: bool = false
@export var debug_text: RichTextLabel
@export var input_text: LineEdit

var is_open: bool = false
var commands: Dictionary[String, Callable] = {}
var last_commands: Array[String]
var last_index: int
var _logger: Logger


## Initializes the debug console, registers default commands, and sets up the custom logger.
func _ready () -> void:
	input_text.text_submitted.connect(_handle_text_submitted)
	add_command("time", _set_time_scale)
	add_command("fps", _set_fps)
	# Setup custom logger for intercepting print calls in non-editor builds
	if not Engine.is_editor_hint():
		_logger = preload("res://Modules/Debug/debug_logger.gd").new()
		_logger.setup(debug_text)
		OS.add_logger(_logger)
	visible = false


## Handles keyboard shortcuts for toggling visibility, zooming, and navigating command history.
func _unhandled_input (event: InputEvent) -> void:
	if disable or event is not InputEventKey or Engine.is_editor_hint():
		return
	# F7 toggles game pause state
	if event.keycode == KEY_F7 and event.pressed and not event.echo:
		get_tree().paused = not get_tree().paused
		return
	# Escape toggles console visibility
	if event.is_action_released("ui_cancel"):
		is_open = !is_open
		visible = is_open
		if is_open:
			input_text.grab_focus()
	# Up/Down arrows navigate through command history
	elif is_open and last_commands.size() > 0:
		if event.keycode == KEY_UP:
			last_index = clamp(last_index - 1, -last_commands.size(), -1)
			input_text.text = last_commands[last_index]
		elif event.keycode == KEY_DOWN:
			last_index = clamp(last_index + 1, -last_commands.size(), 0)
			if last_index == 0:
				input_text.text = ""
			else:
				input_text.text = last_commands[last_index]


## @deprecated("Use print() instead — messages are now intercepted automatically by the Logger.")
## @deprecated("Use print() instead — messages are now intercepted automatically by the Logger.")
func logm (msg: String) -> void:
	print(msg)


## @deprecated("Use push_warning() instead — warnings are now intercepted automatically by the Logger.")
## @deprecated("Use push_warning() instead — warnings are now intercepted automatically by the Logger.")
func log_warning (msg: String) -> void:
	push_warning(msg)


## @deprecated("Use push_error() instead — errors are now intercepted automatically by the Logger.")
## @deprecated("Use push_error() instead — errors are now intercepted automatically by the Logger.")
func log_error (msg: String) -> void:
	push_error(msg)


## Registers a new debug command with its associated callback.
func add_command (func_name: String, callable: Callable) -> void:
	commands[func_name] = callable


## Parses and calls the command specified by the input string.
func call_command (text: String) -> void:
	input_text.clear()
	_register_command_executed(text)
	var has_params = text.find(" ") != -1
	# Handle commands with parameters
	if has_params:
		var split = text.split(" ")
		var func_name = split[0]
		var str_params = split.slice(1, split.size())
		var params = []
		# Convert string parameters to appropriate types (bool, int, float)
		for p in str_params:
			if p == str(true):
				params.append(true)
			elif p == str(false):
				params.append(false)
			elif p.is_valid_int():
				params.append(p.to_int())
			elif p.is_valid_float():
				params.append(p.to_float())
			else:
				params.append(p)
		if commands.has(func_name):
			commands[func_name].callv(params)
			print("Function executed: " + func_name + " with params: " + str(params))
		else:
			push_warning("Command not found: " + func_name)
	# Handle parameterless commands
	elif commands.has(text):
		if commands[text].get_argument_count() > 0:
			push_warning("Command requires parameters: " + text)
		else:
			commands[text].call()
			print("Function executed: " + text)
	else:
		push_warning("Command not found: " + text)
	call_deferred("_grab_focus_back")


## Static convenience method to call a global debug command.
static func call_command_static (text: String) -> void:
	Debug.call_command(text)


## Internal tracking for executed command history.
func _register_command_executed (text: String) -> void:
	if not last_commands.has(text):
		last_commands.append(text)


## Internal handler for text submission from the console's Input field.
func _handle_text_submitted (text: String) -> void:
	call_command(text)


## Internal helper to restore keyboard focus to the input field.
func _grab_focus_back () -> void:
	visible = false
	visible = true
	input_text.grab_focus()


## Internal command implementation for setting engine time scale.
func _set_time_scale (value: float) -> void:
	value = clamp(value, 0.0, 3.0)
	Engine.time_scale = value


## Internal command implementation for capping engine maximum FPS.
func _set_fps (value: int) -> void:
	value = max(0, value)
	Engine.max_fps = value
