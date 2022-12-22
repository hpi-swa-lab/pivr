extends Node

# It is difficult for GReaSe to access mouse events because these do not exist
# as a node in Godot, instead they are tacked on using virtual functions

signal event(event)
signal button(pressed, button, position)
signal keyboard(pressed, scan_code, unicode)

var mouse_position = Vector2(0, 0)
var relative_mouse_motion = Vector2(0, 0)

func _input(event):
	emit_signal("event", event)
	if event is InputEventMouseMotion:
		mouse_position = event.global_position
		relative_mouse_motion = event.relative
	if event is InputEventMouseButton:
		emit_signal("button", event.pressed, event.button_index, event.global_position)
	if event is InputEventKey:
		emit_signal("keyboard", event.pressed, event.scancode, event.unicode)

# sadly, Viewport::_gui_find_control is private :(
func controls_at_position(position: Vector2):
	var result = []
	_controls_at_position(get_tree().get_root(), position, result)
	return result

func _controls_at_position(parent: Node, position: Vector2, result: Array):
	for child in parent.get_children():
		# TODO no support for rotated controls. Also consider using CanvasItem instead
		if child is Control and child.get_global_rect().has_point(position):
			result.append(child)
		_controls_at_position(child, position, result)
