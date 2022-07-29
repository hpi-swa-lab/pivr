extends Spatial

class_name TSBlock

var color = Color.white setget set_color
var is_flat

var id

var morph_position
var morph_extent

export(float) var block_scale
export(float) var block_thickness

func build_from_structure(structure):
	id = int(structure["id"])
	
	var morph_bounds = structure["bounds"]
	morph_position = Vector2(morph_bounds[0], morph_bounds[1])
	morph_extent = Vector2(morph_bounds[2], morph_bounds[3])
	
	set_color(Color(structure["color"]))
	
	is_flat = structure["highlight"].ends_with(".part")
	$Scaled/MeshInstance.visible = !is_flat
	$Scaled/Area.monitorable = !is_flat
	
	for child_structure in structure["children"]:
		var child = null
		match child_structure["class"]:
			"block":
				child = load("res://TSBlock/TSBlock.tscn").instance()
			"text":
				child = preload("res://TSText/TSText.tscn").instance()
			"hardLineBreak":
				pass
			_:
				print("Tried to build unknown block class ", child_structure["class"])
		if child != null:
			child.build_from_structure(child_structure)
			$Blocks.add_child(child)
			child.adjust_to_parent()

func adjust_to_parent():
	# assumption: parent is a TSBlock
	var parent = get_parent().get_parent()
	block_scale = parent.block_scale
	block_thickness = 0 if is_flat else parent.block_thickness
	
	var origin = Vector3()
	origin.x = morph_position.x - parent.morph_position.x + (morph_extent.x - parent.morph_extent.x) / 2
	origin.y = morph_position.y - parent.morph_position.y + (morph_extent.y - parent.morph_extent.y) / 2
	origin.y *= -1
	origin *= block_scale
	origin.z = parent.block_thickness / 2 if is_flat else block_thickness
	transform.origin = origin
	
	apply_block_scale()
	
	for child in $Blocks.get_children():
		child.adjust_to_parent()

func apply_block_scale():
	$Scaled.scale = Vector3(morph_extent.x * block_scale, morph_extent.y * block_scale, block_thickness)

func set_flat(is_flat):
	$Scaled/MeshInstance.visible = !is_flat
	$Scaled/Area.monitorable = !is_flat
	for child in get_children():
		if child.is_in_group("tsblock"):
			child.transform.origin.z = 0 if is_flat else 0.005
		if child.is_in_group("tstext"):
			child.transform.origin.z = -0.0049 if is_flat else 0.0051

func get_editor():
	for node in get_tree().get_nodes_in_group("editor"):
		return node
	return null

func get_provider():
	return get_editor().get_node("Provider")

func on_hover_in():
	highlight(true)

func on_hover_out():
	unhighlight(true)

func on_grab():
#	if !is_root_block():
	return get_editor().pickUpBlock_(id) != null

func on_release():
#	get_parent().remove_child(self)
	get_provider().clearInsertHighlights()
	fix_orientation()

func fix_orientation():
	if is_root_block():
		var angles = global_transform.basis.get_euler()
		angles.z = 0
		var dest_basis = Basis(angles)
		$Tween.interpolate_property(self, "global_transform:basis", global_transform.basis, dest_basis, .3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()
	else:
		get_parent().fix_orientation()

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

func append_text(new_text):
	get_editor().appendText_toNodeWithId_(new_text, id)
