extends Spatial

class_name TSBlock

var color = Color.white setget set_color
var id

func get_editor():
	for node in get_tree().get_nodes_in_group("editor"):
		return node
	return null

func on_hover_in():
	highlight(true)

func on_hover_out():
	unhighlight(true)

func on_grab():
#	if !is_root_block():
	return get_editor().pickUpBlock_(id) != null

func on_release():
#	get_parent().remove_child(self)
	pass

func set_block_scale(s):
	$Scaled.scale = s

func get_dimensions():
	return $Scaled.scale

func is_root_block():
	return get_parent() != null and !get_parent().is_in_group("tsblock")

func set_color(value):
	color = value
	$Scaled/MeshInstance.get_surface_material(0).albedo_color = color
	for child in get_children():
		if child.is_in_group("tsblock"):
			child.color = color.darkened(.1)

func highlight(highlight_children = false):
	$Scaled/MeshInstance.get_surface_material(0).next_pass = preload("res://TSBlock/HighlightMaterial.tres")
	if highlight_children:
		for child in get_children():
			if child.is_in_group("tsblock"):
				child.highlight(true)

func unhighlight(unhighlight_children = false):
	$Scaled/MeshInstance.get_surface_material(0).next_pass = null
	if unhighlight_children:
		for child in get_children():
			if child.is_in_group("tsblock"):
				child.unhighlight(true)

func get_block_children():
	var children = []
	for child in get_children():
		if child.is_in_group("tsblock") or child.is_in_group("tstext"):
			children.append(child)
	return children
