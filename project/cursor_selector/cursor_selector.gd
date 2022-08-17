tool

extends Spatial

const INDEX_TRIGGER = 15
const INDEX_A = JOY_BUTTON_7

export(float) var minimum_distance = 0.08
export(float) var maximum_distance = 0.15

var last_placed_cursor
var button_is_pressed = false
var last_hovered_node

func above_max_distance():
	return !$RayCast.is_colliding()

func ray_cast_distance():
	return $RayCast.get_collision_point().distance_to($RayCast.global_transform.origin)

func is_pointing_at_selectable():
	return $RayCast.is_colliding() \
		and ray_cast_distance() >= minimum_distance \
		and $RayCast.get_collider().get_grabbed_node().has_method("is_selectable") \
		and $RayCast.get_collider().get_grabbed_node().is_selectable()

func _on_button_pressed(button):
	if button != INDEX_TRIGGER and button != INDEX_A:
		return
	
	button_is_pressed = true
	
	if !is_pointing_at_selectable():
		return
	
	match button:
		INDEX_TRIGGER:
			$RayCast.get_collider().get_grabbed_node().select_at($RayCast.get_collision_point())
		INDEX_A:
			$RayCast.get_collider().get_grabbed_node().compile()

func _on_button_release(button):
	if button != INDEX_TRIGGER and button != INDEX_A:
		return
	
	button_is_pressed = false

func get_colliding_block():
	return $RayCast.get_collider().get_grabbed_node()

func init_detection():
	$RayCast.cast_to = Vector3.FORWARD * maximum_distance
	$MinimumDistanceViz.transform.origin = $RayCast.cast_to.normalized() * minimum_distance

func _ready():
	init_detection()

func _process(_delta):
	if Engine.editor_hint:
		init_detection()
		return
	
	if last_placed_cursor != null:
		if button_is_pressed or last_placed_cursor.is_preview:
			last_placed_cursor.remove()
		last_placed_cursor = null
	
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
		
		var block = get_colliding_block()
		if block.has_method("add_cursor_at_position"):
			if owner.may_place_cursors():
				last_placed_cursor = block.add_cursor_at_position(end_point, !button_is_pressed)
		elif block.has_method("hover_select_at"):
			block.hover_select_at(end_point)
		switch_last_hovered_node(block)
	else:
		$RayViz.visible = false
		switch_last_hovered_node()

func switch_last_hovered_node(new_node = null):
	if last_hovered_node != new_node and last_hovered_node != null and last_hovered_node.has_method("unhover_select"):
		last_hovered_node.unhover_select()
	last_hovered_node = new_node
	if new_node != null:
		new_node.connect("tree_exited", self, "last_hovered_node_exited", [new_node])

func node_exited(node):
	if node == last_hovered_node:
		last_hovered_node = null
