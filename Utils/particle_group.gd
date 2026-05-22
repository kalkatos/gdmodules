@tool
## Utility for synchronizing multiple GPUParticles3D emitters to play in unison
class_name ParticleGroup
extends Node

signal group_emitted

@export var emitting: bool:
	get:
		# return group.any(func(p): p and p.emitting)
		return group.any(func(p): return p and p.emitting)
	set(value):
		emit(value)
@export var emitter_group: Array[ParticleEmitter] = []
@export var group: Array[Node] = []


func emit (on: bool = true) -> void:
	for node in group:
		node.emitting = on
	for emitter in emitter_group:
		var node = get_node(emitter.particle)
		if emitter.delay > 0.0:
			var timer = get_tree().create_timer(emitter.delay)
			timer.timeout.connect(func(): node.emitting = on )
		else:
			node.emitting = on
	group_emitted.emit()
