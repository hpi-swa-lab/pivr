class_name Grabber

extends Area

enum Button {
	NONE,
	INDEX_TRIGGER = 15,
	INDEX_GRIP = 2,
}

enum Mode {
	Move,
	Interact,
}

export(Dictionary) var highlight_args = {}
export(Button) var activation_button = Button.INDEX_TRIGGER
export(bool) var grab_root = false

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
		if grab_root and hovered_node.has_method("get_root_block"):
			hovered_node = hovered_node.get_root_block()
	if hovered_node != null and hovered_node.has_method("on_hover_in"):
		hovered_node.on_hover_in(highlight_args)
	if hovered_node != last_hovered_node:
		if last_hovered_node != null and last_hovered_node.has_method("on_hover_out"):
			last_hovered_node.on_hover_out()
		last_hovered_node = hovered_node

func is_grabbing():
	return grabbed_node != null

func _on_button_pressed(button):
	if button != activation_button:
		return
	
	var best = best_colliding_object()
	if best == null:
		return
	grabbed_node = best.get_grabbed_node()
	if grab_root and grabbed_node.has_method("get_root_block"):
		grabbed_node = grabbed_node.get_root_block()
	
	var delta_transform = global_transform.inverse() * grabbed_node.global_transform
	if grabbed_node.has_method("on_grab"):
		if not grabbed_node.on_grab(Mode.Move if grab_root else Mode.Interact):
			grabbed_node = null
			return
	
	$RemoteTransform.transform = delta_transform
	$RemoteTransform.remote_path = grabbed_node.get_path()

func _on_button_release(button):
	if button != activation_button:
		return

	if grabbed_node != null:
		$RemoteTransform.remote_path = ""
		if grabbed_node.has_method("on_release"):
			grabbed_node.on_release()
			if last_hovered_node and last_hovered_node.has_method("on_drop"):
				last_hovered_node.on_drop(grabbed_node)
		grabbed_node = null
