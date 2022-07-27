extends Spatial

var points = []
var write = Write.new()

export(NodePath) var label_node
export(NodePath) var controller_node
export(NodePath) var grabber

func _ready():
	$Path.curve.clear_points()

func get_controller_position():
	var node = get_node(controller_node)
	var pos_node = node.get_node("AirwritePos")
	if pos_node != null:
		node = pos_node
	return node.global_transform.origin

func get_controller_active():
	var use_touchpad = false
	var ctrl = get_node(controller_node)
	if use_touchpad:
		return ctrl.get_joystick_axis(6) != 0
	else:
		return not get_node(grabber).grabbed_node and ctrl.is_button_pressed(JOY_VR_TRIGGER)

func get_my_origin():
	return get_node(controller_node).get_parent().get_node("ARVRCamera").global_transform.origin

func _process(delta):
	if not get_controller_active():
		if not points.empty():
			write.detect_chars(points, funcref(self, 'direction_of_stroke'), get_node(label_node), 0.03)
			points = []
			$Path.curve.clear_points()
		return
	
	var pos = get_controller_position()
	if pos != null:
		points.append(pos)
		$Path.curve.add_point(pos)

func direction_of_stroke(p1: Vector3, p2: Vector3):
	var delta = (p1 - p2).abs()
	var origin = get_my_origin()
	if sqrt(delta.x * delta.x + delta.z * delta.z) > delta.y:
		var a = p1 - origin
		var b = p2 - origin
		return 'l' if Vector2(a.x, a.z).angle_to(Vector2(b.x, b.z)) < 0 else 'r'
	else:
		return 'u' if p2.y > p1.y else 'd'
