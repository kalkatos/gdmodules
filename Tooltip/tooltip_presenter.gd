## Manages the positioning and visibility of tooltips based on global signals.
class_name TooltipPresenter
extends TooltipControl

@export var time_to_show: float = 0.5
@export var label: RichTextLabel
@export var max_tooltip_width: float = 350.0

var _is_hovering: bool = false
var _timer: float = 0.0

const DISMISS_DISTANCE_THRESHOLD: float = 1.4
const CORNER_OFFSET: Vector2 = Vector2(5, 15)


## Called when the node is ready. Connects signals for showing and hiding tooltips.
func _ready () -> void:
	SignalBus._on_show_tooltip.connect(_handle_show_tooltip)
	SignalBus._on_hide_tooltip.connect(_handle_hide_tooltip)


func _exit_tree () -> void:
	SignalBus._on_show_tooltip.disconnect(_handle_show_tooltip)
	SignalBus._on_hide_tooltip.disconnect(_handle_hide_tooltip)


func _process (delta: float) -> void:
	if _is_hovering and not _is_open and _timer > 0.0:
		_timer -= delta
		if _timer <= 0.0:
			_timer = 0.0
			_present_tooltip()


## Updates the tooltip position whenever the mouse moves.
func _input (event: InputEvent) -> void:
	if (event is InputEventMouseButton
		or (event is InputEventMouseMotion
			and event.screen_relative.length() > DISMISS_DISTANCE_THRESHOLD)):
		_dismiss_tooltip()
		

func _present_tooltip () -> void:
	var mouse_pos = get_global_mouse_position()
	var screen_size = get_window().content_scale_size
	if mouse_pos.x > screen_size.x - target.size.x:
		mouse_pos.x -= target.size.x + CORNER_OFFSET.x
	if mouse_pos.y < target.size.y:
		mouse_pos.y += target.size.y + CORNER_OFFSET.y
	set_position_screen_clamped(mouse_pos)
	open()


func _dismiss_tooltip () -> void:
	_timer = time_to_show
	if _is_hovering and _is_open:
		close()


## Displays the tooltip with the provided data and positions it near the mouse.
func _handle_show_tooltip (data: Variant) -> void:
	if label.autowrap_mode != TextServer.AUTOWRAP_OFF:
		label.custom_minimum_size = Vector2.ZERO
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_is_hovering = true
	_timer = time_to_show
	_write_tooltip(data)
	target.reset_size()
	update_minimum_size()
	if label.size.x > max_tooltip_width:
		label.custom_minimum_size = Vector2(max_tooltip_width, label.size.y)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		target.reset_size()
		update_minimum_size()
	if _is_closing:
		target.visible = false


## Hides the tooltip and clears the label.
func _handle_hide_tooltip () -> void:
	_timer = 0.0
	_is_hovering = false
	close()


func _write_tooltip (data: Variant) -> void:
	label.text = str(data)
