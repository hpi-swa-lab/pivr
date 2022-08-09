extends Spatial

var value: String setget set_value
var dimensions = Vector2.ONE setget set_dimensions

signal selected

func set_value(v):
	value = v
	$TextQuad.content = value
	update_text_position()

func set_dimensions(value):
	dimensions = value
	
	$Scaled.scale.x = dimensions.x
	$Scaled.scale.y = dimensions.y

	$TextQuad.scale.x = dimensions.y
	$TextQuad.scale.y = dimensions.y
	$TextQuad.max_width = dimensions.x
	update_text_position()

func update_text_position():
	var pos = (dimensions - $TextQuad.get_dimensions()) / 2
	pos.x *= -1
	$TextQuad.transform.origin = Vector3(pos.x, pos.y, $TextQuad.transform.origin.z)

func is_selectable():
	return true

func select_at(_global_point):
	emit_signal("selected", value)
