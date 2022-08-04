extends Spatial

var block
var text_block
var index: int setget set_index
var label
var x_range
var is_preview = true setget set_is_preview

func remove():
	queue_free()

func set_cursor_height(height):
	$Scaled.scale.y = height

func get_depth():
	return $Scaled.scale.z

func set_index(value):
	index = value
	var font = label.get_font("font")
	
	var string_width = font.get_string_size(label.text.substr(0, index)).x
	if label.text.empty():
		transform.origin.x = 0
	else:
		transform.origin.x = x_range * string_width / font.get_string_size(label.text).x - x_range / 2

func set_is_preview(value):
	is_preview = value
	$Scaled/MeshInstance.get_surface_material(0).albedo_color.a = 0.5 if is_preview else 1
	
	var groups = ["normal_cursor", "preview_cursor"]
	if is_preview:
		groups.invert()
	add_to_group(groups[0])
	remove_from_group(groups[1])

func get_editor():
	for node in get_tree().get_nodes_in_group("editor"):
		return node
	return null

func write_character(character):
	# guard against some default sandblocks behaviour that we don't want
	if (index == 0 and character == '\b') or character == ' ':
		return
	
	get_editor().writeCharacter_at_inBlockWithId_(character, index + 1, block.id)

func set_in_sandblocks():
	get_editor().startInputAt_inTextWithId_(index + 1, text_block.id)

func ready():
	set_is_preview(is_preview)
