extends Spatial

class_name TSBlock

var color = Color.white setget set_color
var is_flat

var id

var morph_position
var morph_extent

export(float) var block_scale
export(float) var block_thickness

func assume_structure(structure):
	var morph_bounds = structure["bounds"]
	morph_position = Vector2(morph_bounds[0], morph_bounds[1])
	morph_extent = Vector2(morph_bounds[2], morph_bounds[3])
	
	set_color(Color(structure["color"]))
	
	is_flat = structure["highlight"].ends_with(".part")
	$Scaled/MeshInstance.visible = !is_flat
	$Scaled/Area.monitorable = !is_flat

func build_from_structure(structure):
	id = int(structure["id"])
	
	assume_structure(structure)
	
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
	var parent = get_parent_block()
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

func register_self_and_children_if_necessary():
	if !get_provider().idToBlock.has(id):
		get_provider().idToBlock[id] = self
	for child in $Blocks.get_children():
		child.register_self_and_children_if_necessary()

func add_child_block(block, index):
	$Blocks.add_child(block)
	$Blocks.move_child(block, index)
	block.adjust_to_parent()

func remove_child_block(block):
	$Blocks.remove_child(block)

func sync_layout():
	get_editor().syncLayoutForBlockWithId_(id)

func sync_to_layout_structure(structure):
	
	assume_structure(structure)
	if !is_root_block():
		adjust_to_parent()
	else:
		apply_block_scale()
	
	for child_structure in structure["children"]:
		if child_structure["class"] in ["block", "text"]:
			var child = get_child_block_with_id(int(child_structure["id"]))
			child.sync_to_layout_structure(child_structure)

func add_cursor_at_position(global_point, preview=false):
#	Logger.log(get_cursor_infos_for_global_position(global_point))
	for child in get_block_children():
		if child.is_in_group("tstext"):
			return child.add_cursor_at_position(global_point, preview)

func get_cursor_infos_for_global_position(global_point):
	var morphic_point = local_point_to_morphic(to_local(global_point)) 
	return get_editor().getCursorInfosForBlockWithId_atPoint_(id, morphic_point)

func local_point_to_morphic(point):
	# assumption: point is on surface of block, so we can ignore the z axis
	point = Vector2(point.x, -point.y)
	var morphic_point = (point / block_scale) + morph_extent / 2 + morph_position
	return morphic_point

func get_child_block_with_id(id):
	for child in $Blocks.get_children():
		if child.id == id:
			return child
	return null

func get_root_block():
	if is_root_block():
		return self
	else:
		return get_parent_block().get_root_block()

func get_parent_block():
	return get_parent().get_parent()

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
	return get_parent_block() != null and !get_parent_block().is_in_group("tsblock")

func set_color(value):
	color = value
	$Scaled/MeshInstance.get_surface_material(0).albedo_color = color
#	for child in get_block_children():
#		if child.is_in_group("tsblock"):
#			child.color = color.darkened(.1)

func highlight(highlight_children = false):
	$Scaled/MeshInstance.get_surface_material(0).next_pass = preload("res://TSBlock/HighlightMaterial.tres")
	if highlight_children:
		for child in get_block_children():
			if child.is_in_group("tsblock"):
				child.highlight(true)

func unhighlight(unhighlight_children = false):
	$Scaled/MeshInstance.get_surface_material(0).next_pass = null
	if unhighlight_children:
		for child in get_block_children():
			if child.is_in_group("tsblock"):
				child.unhighlight(true)

func get_block_children():
	return $Blocks.get_children()

func append_text(new_text):
	get_editor().appendText_toNodeWithId_(new_text, id)

func is_selectable():
	for child in get_block_children():
		if child.is_in_group("tstext"):
			return true
	return false
