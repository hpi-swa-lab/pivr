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

func highlight(highlight_children = false):
	$MeshInstance.get_surface_material(0).next_pass = preload("res://TSBlock/HighlightMaterial.tres")
	if highlight_children:
		for child in get_children():
			if child.is_in_group("tsblock"):
				child.highlight(true)

func unhighlight(unhighlight_children = false):
	$MeshInstance.get_surface_material(0).next_pass = null
	if unhighlight_children:
		for child in get_children():
			if child.is_in_group("tsblock"):
				child.unhighlight(true)
