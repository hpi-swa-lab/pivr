extends Spatial

class_name TSBlock

var color = Color.white setget set_color
var display_color setget , get_display_color
var is_flat

var id
var is_method_root
var is_vr_interaction_allowed

var morph_position
var morph_extent

export(float) var block_scale
export(float) var block_thickness

func assume_structure(structure):
	var morph_bounds = structure["bounds"]
	morph_position = Vector2(morph_bounds[0], morph_bounds[1])
	morph_extent = Vector2(morph_bounds[2], morph_bounds[3])
	
	set_color(Color(structure["color"]))
	
	if structure.has("highlight"):
		is_flat = structure["highlight"].ends_with(".part")
	$Scaled/MeshInstance.visible = !is_flat
	$Area.monitorable = !is_flat
	
	is_method_root = structure["type"] == "methodRoot" or structure["type"] == "genericRoot"
	is_vr_interaction_allowed = structure["vrInteractionAllowed"]

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
	
	$Area.transform.origin.z = get_parent_block().block_thickness / 2 if is_flat else 0
	
	if color == parent.color:
		display_color = parent.display_color.darkened(.025)
		$Scaled/MeshInstance.get_surface_material(0).albedo_color = display_color
	
	apply_block_scale()
	
	for child in $Blocks.get_children():
		child.adjust_to_parent()

func apply_block_scale():
	var sx = morph_extent.x * block_scale
	var sy = morph_extent.y * block_scale
	$Scaled.scale = Vector3(sx, sy, block_thickness)
	var area_thickness = get_parent_block().block_thickness if has_parent_block() and is_flat else block_thickness
	$Area.scale = Vector3(sx, sy, area_thickness)

func has_parent_block():
	return get_parent() != null and get_parent_block() != null and get_parent_block().is_in_group("tsblock")

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

func select_at(global_point):
	add_cursor_at_position(global_point)

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
	if !is_inside_tree():
		Logger.warn(["Attempted to get editor in orphaned block with id ", id])
		return null
	for node in get_tree().get_nodes_in_group("editor"):
		return node
	return null

func get_provider():
	var editor = get_editor()
	if editor == null:
		return null
	else:
		return get_editor().get_node("Provider")

func on_hover_in(args = {}):
	highlight(true, args.get("highlight_color_name", "green"))

func on_hover_out():
	unhighlight(true)

func on_grab(mode):
	if !is_inside_tree():
		Logger.warn("Attempted to pick up orphaned block")
		return false
	
	var allow
	match mode:
		Grabber.Mode.Move:
			# we can always safely move blocks in godot space
			allow = self.is_root_block()
		Grabber.Mode.Interact:
			allow = is_vr_interaction_allowed
		_:
			Logger.error("TSBlock: unknown grab mode")
	
	if allow:
		return get_editor().pickUpBlock_showingInsertPositions_(id, !is_method_root) != null
	else:
		return false

func on_release():
#	get_parent().remove_child(self)
	if !is_method_root:
		var provider = get_provider()
		if provider != null:
			get_provider().clearInsertHighlights()
	fix_orientation()

func fix_orientation():
	if is_root_block():
		var angles = global_transform.basis.get_euler()
		angles.z = 0
		var dest_basis = Basis(angles)
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_transform:basis", dest_basis, .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		get_parent_block().fix_orientation()

func get_dimensions():
	return $Scaled.scale

func is_root_block():
	if get_parent() == null:
			Logger.warn(["Attempted to determine root block status for orphaned block with id ", id])
			return self
	return get_parent_block() != null and !has_parent_block()

func set_color(value):
	color = value
	$Scaled/MeshInstance.get_surface_material(0).albedo_color = color
#	for child in get_block_children():
#		if child.is_in_group("tsblock"):
#			child.color = color.darkened(.1)

func get_display_color():
	return color if display_color == null else display_color

func highlight(highlight_children = false, color_name = "green"):
	$Scaled/MeshInstance.get_surface_material(0).next_pass = {
		"green": preload("res://TSBlock/HighlightMaterial.tres"),
		"blue": preload("res://TSBlock/HighlightMaterialBlue.tres"),
	}[color_name]
	if highlight_children:
		for child in get_block_children():
			if child.is_in_group("tsblock"):
				child.highlight(true, color_name)

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

func compile():
	if is_root_block():
		if is_method_root:
			Logger.log("Attempting to compile...")
			var success = get_editor().compileBlockWithId_(id)
			if success:
				Logger.log("Compilation successful")
			else:
				Logger.error("Compilation failed")
		else:
			Logger.error(["attempted to compile non-method root (id :", id, ")"])
	else:
		get_root_block().compile()

func add_cursor_insert_position(cursor_insert_position_info):
	var cursor_insert_position = preload("res://cursor_insert_position/cursor_insert_position.tscn").instance()
	cursor_insert_position.cursor_id = int(cursor_insert_position_info["id"])
	add_child(cursor_insert_position)
	
	var bounds = cursor_insert_position_info["localBounds"]
	# position is in local coordinates, relative to containing block
	var cursor_morph_position = Vector2(bounds[0], bounds[1])
	var cursor_morph_extent = Vector2(bounds[2], bounds[3])
	
	var position = cursor_morph_position + (cursor_morph_extent - morph_extent) / 2
	position.y *= -1
	position *= block_scale
	cursor_insert_position.transform.origin = Vector3(position.x, position.y, cursor_insert_position.get_depth() / 2)
	
	cursor_insert_position.set_dimensions(cursor_morph_extent * block_scale)
