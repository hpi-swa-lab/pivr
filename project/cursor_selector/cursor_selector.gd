tool

extends Spatial

const INDEX_TRIGGER = 15

export(float) var minimum_distance = 0.08
export(float) var maximum_distance = 0.15

func above_max_distance():
	return !$RayCast.is_colliding()

func ray_cast_distance():
	return $RayCast.get_collision_point().distance_to($RayCast.global_transform.origin)

func is_pointing_at_selectable():
	return $RayCast.is_colliding() \
		and ray_cast_distance() >= minimum_distance \
		and $RayCast.get_collider().get_grabbed_node().is_selectable()

func _on_button_pressed(button):
	if button != INDEX_TRIGGER:
		return
	
	if is_pointing_at_selectable():
		var block = $RayCast.get_collider().get_grabbed_node()
		block.add_cursor_at_position($RayCast.get_collision_point())

func init_detection():
	$RayCast.cast_to = Vector3.FORWARD * maximum_distance
	$MinimumDistanceViz.transform.origin = $RayCast.cast_to.normalized() * minimum_distance

func _ready():
	init_detection()

func _process(_delta):
	if Engine.editor_hint:
		init_detection()
		return
	
	if is_pointing_at_selectable():
		$RayViz.visible = true
		var start_point = global_transform.origin
		var end_point = $RayCast.get_collision_point()
		var center_point = (start_point + end_point) / 2
		$RayViz.global_transform.origin = center_point
		var up = end_point - start_point
		var n1 = (Vector3.UP if Vector3.UP.angle_to(up) > 0.1 else Vector3.RIGHT).cross(up).normalized()
		var n2 = up.cross(n1).normalized()
		$RayViz.global_transform.basis = Basis(n1, up, n2)
	else:
		$RayViz.visible = false
