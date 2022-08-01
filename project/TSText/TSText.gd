class_name TSText

extends Spatial

var contents setget set_contents
var color setget set_color

var id

var morph_position
var morph_extent

func build_from_structure(structure):
	id = int(structure["id"])
	assume_structure(structure)

func sync_to_layout_structure(structure):
	assume_structure(structure)
	adjust_to_parent()
	for child in $CursorContainer.get_children():
		# trigger repositioning
		child.index = child.index

func assume_structure(structure):
	set_contents(structure["contents"])
	set_color(Color(structure["color"]))
	
	var morph_bounds = structure["bounds"]
	morph_position = Vector2(morph_bounds[0], morph_bounds[1])
	morph_extent = Vector2(morph_bounds[2], morph_bounds[3])

func adjust_to_parent():
	# assumption: parent is a TSBlock
	var parent = get_parent_block()
	
	var origin = Vector3()
	origin.x = morph_position.x - parent.morph_position.x + (morph_extent.x - parent.morph_extent.x) / 2
	origin.y = morph_position.y - parent.morph_position.y + (morph_extent.y - parent.morph_extent.y) / 2
	origin *= parent.block_scale
	origin.z = parent.block_thickness / 2 + 0.0001
	transform.origin = origin
	
	$MeshInstance.scale = Vector3(morph_extent.x * parent.block_scale, morph_extent.y * parent.block_scale, parent.block_thickness)
	$CursorContainer.transform.origin.x = -$MeshInstance.scale.x / 2
	for child in $CursorContainer.get_children():
		child.x_range = $MeshInstance.scale.x

func get_parent_block():
	return get_parent().get_parent()

func add_cursor_at(global_point):
	get_tree().call_group("cursor", "remove")
	var cursor = preload("res://cursor/cursor.tscn").instance()
	$CursorContainer.add_child(cursor)
	cursor.set_cursor_height($MeshInstance.scale.y)
	cursor.transform.origin.z = cursor.get_depth() / 2
	cursor.x_range = $MeshInstance.scale.x
	cursor.label = $Viewport/Label
	cursor.block = get_parent_block()
	
	var local_point = to_local(global_point)
	var width = $MeshInstance.scale.x
	var distance_percentage = (local_point.x + width / 2) / width
	var label_width = $Viewport/Label.rect_size.x
	var threshold_width = label_width * distance_percentage
	var font = $Viewport/Label.get_font("font")
	for i in range(1, contents.length() + 1):
		var s = contents.substr(0, i)
		var string_width = font.get_string_size(s).x
		if string_width >= threshold_width:
			cursor.index = i
			break

func set_color(value):
	color = value
	$Viewport/Label.add_color_override("font_color", color)

func set_contents(aString):
	contents = aString
	$Viewport/Label.text = contents
	if get_tree() != null:
		yield(get_tree(), "idle_frame")
		$Viewport.size = $Viewport/Label.rect_size

func register_self_and_children_if_necessary():
	if !get_provider().idToBlock.has(id):
		get_provider().idToBlock[id] = self

func set_block_scale(s):
	$MeshInstance.scale = s

func get_dimensions():
	return $MeshInstance.scale
	
func _ready():
	$Viewport.size = $Viewport/Label.rect_size

func get_block_children():
	return []

func get_editor():
	for node in get_tree().get_nodes_in_group("editor"):
		return node
	return null

func get_provider():
	return get_editor().get_node("Provider")
