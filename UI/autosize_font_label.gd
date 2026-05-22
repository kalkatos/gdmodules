@tool
class_name AutoSizeLabel
## UI component that automatically adjusts font size to fit text within the label's horizontal bounds.
extends Label

@export var max_font_size: int = 56
@export var padding: int = 0


## Initializes the label, enabling clipping and connecting to layout change signals.
func _ready () -> void:
	clip_text = true
	item_rect_changed.connect(_on_item_rect_changed)


## Intercepts text property changes to trigger font size recalculation.
func _set (property: StringName, _value: Variant) -> bool:
	match property:
		"text":
			# listen for text changes
			update_font_size()
	return false


## Recalculates and applies the optimal font size based on current text content and horizontal padding.
func update_font_size () -> void:
	var font = get_theme_font("font")
	var font_size = get_theme_font_size("font_size")
	var line = TextLine.new()
	line.direction = text_direction
	line.flags = justification_flags
	line.alignment = horizontal_alignment
	# Iteratively test font sizes to find the best fit
	for i in 100:
		line.clear()
		var created = line.add_string(text, font, font_size)
		if created:
			var text_size = line.get_line_width()
			# Shrink font if it exceeds available width
			if text_size > floor(size.x - padding * 2) and font_size > 1:
				font_size -= 1
			# Grow font if it's below max size (and presumably fits)
			elif font_size < max_font_size:
				font_size += 1
			else:
				break
		else:
			push_warning('Could not create a string')
			break
	add_theme_font_size_override("font_size", font_size)


## Internal handler for rectangle resizing events.
func _on_item_rect_changed () -> void:
	update_font_size()
