@tool
class_name Sprite3DViewport
## Component that maps a SubViewport's texture to a Sprite3D, enabling 2D UI or scenes to be rendered in 3D space.
extends Sprite3D

@export var vp: SubViewport


## Initializes the sprite by assigning the linked SubViewport's texture.
func _ready () -> void:
	texture = vp.get_texture()
