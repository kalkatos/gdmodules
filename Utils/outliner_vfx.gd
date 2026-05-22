@tool
class_name OutlinerVFX
extends Node

@export var origin_vfx: GPUParticles3D
@export var outline_color: Color = Color(0, 0, 0, 1)
@export_range(0.5, 5.0) var outline_thickness: float = 1.0
@export var outline_texture_suffix: String = "_out"

@export_enum("Mesh Size", "Particle Size", "Texture")
var method: int = 0

@export_tool_button("Duplicate as Outline")
var b1:
	get: return func(): _duplicate_as_outline()


func _duplicate_as_outline() -> void:
	var root = get_tree().get_edited_scene_root()
	origin_vfx.use_fixed_seed = true
	var seed_ = randi()
	origin_vfx.seed = seed_
	print("Duplicating as outline...")
	var outline = origin_vfx.duplicate(DuplicateFlags.DUPLICATE_INTERNAL_STATE) as GPUParticles3D
	print("Adding child...")
	root.add_child(outline)
	print("Setting owner...")
	outline.owner = root
	print("Setting name...")
	outline.name = origin_vfx.name + "_Outline"
	print("Setting process material...")
	outline.process_material = origin_vfx.process_material.duplicate(true)
	print("Setting mesh...")
	outline.draw_pass_1 = origin_vfx.draw_pass_1.duplicate(true)
	print("Setting material...")
	outline.draw_pass_1.material = outline.draw_pass_1.material.duplicate(true)
	print("Setting outline color...")
	outline.draw_pass_1.material.albedo_color = outline_color
	print("Setting sorting offset...")
	outline.sorting_offset = origin_vfx.sorting_offset - 1
	match method:
		0:
			print("Setting outline thickness...")
			outline.draw_pass_1.size *= (1 + 0.1 * outline_thickness)
		1:
			print("Setting outline thickness via curve...")
			var process_material = outline.process_material as ParticleProcessMaterial
			var curve_tex = process_material.scale_curve as CurveTexture
			var curve = curve_tex.curve as Curve
			for i in range(curve.get_point_count()):
				var point = curve.get_point_position(i)
				curve.set_point_value(i, point.y * (1 + 0.1 * outline_thickness))
		2:
			print("Setting outline texture...")
			var original_texture = outline.draw_pass_1.material.albedo_texture
			var original_path = original_texture.resource_path.trim_suffix(".png")
			var new_path = original_path + outline_texture_suffix + ".png"
			if ResourceLoader.exists(new_path):
				var outline_texture = load(new_path) as Texture2D
				outline.draw_pass_1.material.albedo_texture = outline_texture
				print("Outline texture set from path: " + new_path)
			else:
				push_error("Outline texture not found at path: " + new_path)




	