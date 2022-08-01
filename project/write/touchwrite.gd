extends Spatial

export (NodePath) var label_node
export (NodePath) var controller_node

var write = Write.new()

var last_touch_pos
var points = []

const THIN_THRESHOLD = 100

func get_touchpad_position() -> Vector2:
	var ctrl = get_node(controller_node)
	return Vector2(ctrl.get_joystick_axis(6), -ctrl.get_joystick_axis(7))

func _process(_delta):
	var pos = get_touch_pos()
	visible = pos != null
	
	if pos == null:
		if not points.empty():
			write.detect_chars(points, funcref(self, 'direction_of_stroke'), funcref(self, 'handle_result_char'), THIN_THRESHOLD)
			points = []
	else:
		points.append(pos)
		$Viewport/Control.update()

func get_touch_pos():
	var pos = get_touchpad_position()
	if pos == Vector2(0, 0):
		return null
	else:
		return (pos + Vector2(1, 1)) / 2 * $Viewport.size

func _on_Control_draw():
	$Viewport/Control.draw_rect(Rect2(Vector2(0, 0), $Viewport.size), Color.white)
	if not points.empty():
		var last
		for p in points:
			if last:
				$Viewport/Control.draw_line(last, p, Color.gray, 5, true)
			last = p
		last = null
		for p in write.thin_points(points, THIN_THRESHOLD):
			if last:
				$Viewport/Control.draw_line(last, p, color_for_direction(direction_of_stroke(last, p)), 5, true)
			last = p

func color_for_direction(dir):
	match dir:
		'l': return Color.red
		'r': return Color.green
		'u': return Color.blue
		'd': return Color.yellow

func direction_of_stroke(p1, p2):
	var delta = (p1 - p2).abs()
	if delta.x > delta.y:
		return 'l' if p1.x > p2.x else 'r'
	else:
		return 'u' if p1.y > p2.y else 'd'

func handle_result_char(character):
	var label = get_node(label_node)
	if character == '\b':
		label.text = label.text.substr(0, label.text.length() - 1)
	else:
		label.text += character
