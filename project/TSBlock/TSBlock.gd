extends Spatial

class_name TSBlock

var color = Color.white setget set_color

var id

func set_block_scale(s):
	$MeshInstance.scale = s

func get_dimensions():
	return $MeshInstance.scale

func set_color(value):
	color = value
	$MeshInstance.get_surface_material(0).albedo_color = color
	for child in get_children():
		if child.is_in_group("tsblock"):
			child.color = color.darkened(.1)
