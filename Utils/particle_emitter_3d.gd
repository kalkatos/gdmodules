class_name ParticleEmitter3D
## 3D component for triggering and managing one-shot CPUParticles3D effects with automatic pooling support.
extends Node3D

signal finished

@export var particles: CPUParticles3D

var is_playing: bool


## Initializes the emitter and connects to the particle finish signal.
func _ready () -> void:
	is_playing = false
	particles.finished.connect(_handle_particles_finished)


## Triggers the particle effect at the specified position, using pooling if already active.
func play (pos: Vector3) -> void:
	# If already playing, request a pooled instance to handle overlapping effects
	if is_playing:
		var other = Pooler.get_new(self) as ParticleEmitter3D
		var my_parent = get_parent()
		if other.get_parent() != my_parent:
			my_parent.add_child(other)
			other.owner = my_parent
		other.play(pos)
		return
	visible = true
	is_playing = true
	global_position = pos
	particles.restart()


## Internal handler for particle completion; resets state for future use.
func _handle_particles_finished () -> void:
	particles.emitting = false
	is_playing = false
	finished.emit()
	visible = false
