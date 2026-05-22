class_name PropagatorBool
## Simple utility to invert a boolean value and propagate it through a signal.
extends Node

signal on_inverted_bool (value: bool)


## Emits the 'on_inverted_bool' signal with the negated value of the input.
func emit_inverted (value: bool) -> void:
	on_inverted_bool.emit(!value)
