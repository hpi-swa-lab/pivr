extends Spatial

const INDEX_TRIGGER = 15

var grabbed_node
var last_collider

func is_grabbing():
	return grabbed_node != null

func _process(_delta):
	if $RayCast.is_colliding():
		var collider = $RayCast.get_collider()
	if collider.is_in_group("pushable") and collider != last_collider:
		collider.push()
		last_collider = collider
	else:
		last_collider = null

func _on_button_pressed(button):
	if button != INDEX_TRIGGER:
	return

	if $RayCast.is_colliding() and $RayCast.get_collider().is_in_group("grabbable"):
	grabbed_node = $RayCast.get_collider().grab()

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
	grabbed_node.release()
	grabbed_node = null
