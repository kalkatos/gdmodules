class_name DebugLogger
extends Logger
## Custom logger that intercepts all print/push_warning/push_error calls and displays them in the in-game debug panel.
## Registered via OS.add_logger() from global Debug session.

var debug_text: RichTextLabel


## Connects the logger to a RichTextLabel for visual output.
func setup (rich_text_label: RichTextLabel) -> void:
	debug_text = rich_text_label


## Internal callback for basic log messages, handling color formatting if it's an error.
func _log_message (message: String, error: bool) -> void:
	if debug_text == null:
		return
	if error:
		_append_text.call_deferred("[color=red]%s[/color]" % message.strip_edges())
	else:
		_append_text.call_deferred(message.strip_edges())


## Internal callback for detailed engine error reports, formatting with file and line information.
func _log_error (function: String, file: String, line: int, code: String, rationale: String, editor_notify: bool, error_type: int, script_backtraces: Array[ScriptBacktrace]) -> void:
	if debug_text == null:
		return
	var detail = rationale if rationale != "" else code
	var stack_trace = "\n".join(script_backtraces.map(func(b): return b.format(4)))
	var text = "%s\n%s" % [detail, stack_trace]
	match error_type:
		Logger.ERROR_TYPE_WARNING:
			_append_text.call_deferred("[color=yellow]%s[/color]" % text)
		_:
			_append_text.call_deferred("[color=red]%s[/color]" % text)


## Internal helper to safely append text to the linked RichTextLabel on the main thread.
func _append_text (text: String) -> void:
	if debug_text == null:
		return
	debug_text.newline()
	debug_text.append_text(text)
