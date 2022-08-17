extends Spatial

var cursor_id
var is_selected = false

func set_dimensions(value):
	$Scaled.scale.x = value.x
	$Scaled.scale.y = value.y

func get_depth():
	return $Scaled.scale.z

func select():
	if cursor_id == null:
		Logger.error("Tried to select cursor insert position without a cursor_id!")
		return
	
	get_editor().selectCursorInsertPosition_(cursor_id)

func write_character(character):
	if !is_selected:
		return
	
	get_editor().sendKeyStroke_(character)

func remove():
	queue_free()

func get_editor():
	if !is_inside_tree():
		Logger.warn("Attempted to get editor in orphaned cursor insert position!")
		return null
	for node in get_tree().get_nodes_in_group("editor"):
		return node
	return null

func is_selectable():
	return true

func hover_select_at(_global_point):
	if !is_selected:
		$Scaled/MeshInstance.get_surface_material(0).next_pass = preload("res://cursor_insert_position/hover_highlight.tres").duplicate()

func unhover_select():
	$Scaled/MeshInstance.get_surface_material(0).next_pass = null

func select_at(_global_point):
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "cursor_like", "unselect_cursor")
	$Scaled/MeshInstance.set_surface_material(0, preload("res://cursor_insert_position/selected.tres"))
	is_selected = true
	select()

func unselect_cursor():
	$Scaled/MeshInstance.set_surface_material(0, preload("res://cursor_insert_position/normal.tres").duplicate())
	is_selected = false
