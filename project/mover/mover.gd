extends Area

const INDEX_TRIGGER = 15
const INDEX_GRIP = 2

var grabbed_node
var last_hovered_node

func best_colliding_object():
	var best = null
	for object in get_overlapping_areas():
		# TODO
		if object.is_in_group("drop" if grabbed_node else "grabbable"):
			best = object
	return best

func _process(_delta):
	var best = best_colliding_object()
	var hovered_node = null
	if best != null:
		hovered_node = best.get_grabbed_node()
		if hovered_node.has_method("get_root_block"):
			hovered_node = hovered_node.get_root_block()
	if hovered_node != null and hovered_node.has_method("on_hover_in"):
		hovered_node.on_hover_in({"highlight_color_name": "blue"})
	if hovered_node != last_hovered_node:
		if last_hovered_node != null and last_hovered_node.has_method("on_hover_out"):
			last_hovered_node.on_hover_out()
		last_hovered_node = hovered_node

func is_grabbing():
	return grabbed_node != null

func _on_button_pressed(button):
	if button != INDEX_GRIP:
		return
	
	var best = best_colliding_object()
	if best == null:
		return
	grabbed_node = best.get_grabbed_node()
	if grabbed_node.has_method("get_root_block"):
		grabbed_node = grabbed_node.get_root_block()
	
	var delta_transform = global_transform.inverse() * grabbed_node.global_transform
	if grabbed_node.has_method("on_grab"):
		if not grabbed_node.on_grab():
			grabbed_node = null
			return
	
	$RemoteTransform.transform = delta_transform
	$RemoteTransform.remote_path = grabbed_node.get_path()

func _on_button_release(button):
	if button != INDEX_GRIP: # trigger
		return

	if grabbed_node != null:
		$RemoteTransform.remote_path = ""
		if grabbed_node.has_method("on_release"):
			grabbed_node.on_release()
			if last_hovered_node and last_hovered_node.has_method("on_drop"):
				last_hovered_node.on_drop(grabbed_node)
		grabbed_node = null
