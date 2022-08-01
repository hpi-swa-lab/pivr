extends Spatial

const INDEX_TRIGGER = 15

func _on_button_pressed(button):
	if button != INDEX_TRIGGER:
		return
	
	if $RayCast.is_colliding():
		var block = $RayCast.get_collider().get_grabbed_node()
		block.selectCursorAt($RayCast.get_collision_point())
