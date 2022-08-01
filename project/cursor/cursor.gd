extends Spatial

var block
var index setget set_index
var label
var x_range

func remove():
	queue_free()

func set_cursor_height(height):
	$Scaled.scale.y = height

func get_depth():
	return $Scaled.scale.z

func set_index(value):
	index = value
	
	var string_width = label.get_font("font").get_string_size(label.text.substr(0, index)).x
	if label.rect_size.x == 0:
		transform.origin.x = 0
	else:
		transform.origin.x = x_range * string_width / label.rect_size.x

func get_editor():
	for node in get_tree().get_nodes_in_group("editor"):
		return node
	return null

func write_character(character):
	get_editor().writeCharacter_at_inBlockWithId_(character, index + 1, block.id)
	if character == "\b":
		index = index - 1
	else:
		index = index + 1
