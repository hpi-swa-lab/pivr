extends Area

const INDEX_TRIGGER = 15

var grabbed_node
var last_hovered_node

func best_colliding_object():
	var best = null
	for object in get_overlapping_areas():
		# TODO
		if object.is_in_group("grabbable"):
			best = object
	return best

func _process(_delta):
	if grabbed_node == null:
		var best = best_colliding_object()
		var hovered_node = null
		if best != null:
			hovered_node = best.get_grabbed_node()
		if hovered_node != null and hovered_node.has_method("on_hover_in"):
			hovered_node.on_hover_in()
		if hovered_node != last_hovered_node:
			if last_hovered_node != null and last_hovered_node.has_method("on_hover_out"):
				last_hovered_node.on_hover_out()
			last_hovered_node = hovered_node

func is_grabbing():
	return grabbed_node != null

func _on_button_pressed(button):
	if button != INDEX_TRIGGER:
		return
	
	var best = best_colliding_object()
	if best == null:
		return
	grabbed_node = best.get_grabbed_node()
	
	if grabbed_node.has_method("on_grab"):
		if not grabbed_node.on_grab():
			grabbed_node = null
			return

	var position_offset = to_local(grabbed_node.global_transform.origin) - transform.origin
	$RemoteTransform.transform.origin = position_offset

	var rotation_offset = Basis(global_transform.basis.get_rotation_quat().inverse() * grabbed_node.global_transform.basis.get_rotation_quat())
	$RemoteTransform.transform.basis = rotation_offset

	$RemoteTransform.remote_path = grabbed_node.get_path()


func _on_button_release(button):
	if button != INDEX_TRIGGER: # trigger
		return

	if grabbed_node != null:
		$RemoteTransform.remote_path = ""
		if grabbed_node.has_method("on_release"):
			grabbed_node.on_release()
		grabbed_node = null
