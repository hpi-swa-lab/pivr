tool

extends Spatial

export(String) var content = "hello world" setget set_content

var max_width = INF setget set_max_width

func set_content(value):
	content = value
	$Viewport/Label.text = content
	update_size()

func set_max_width(value):
	max_width = value
	update_size()

func update_size():
	var size = $Viewport/Label.get_font("font").get_string_size(content)
	if size.length_squared() == 0:
		size = Vector2.ONE
	else:
		# max_width takes our current scale into account
		size.x = min(size.x, max_width / scale.x * size.y)
	$Viewport.size = size
	$MeshInstance.scale.x = size.x / size.y

func get_dimensions():
	var d = scale * $MeshInstance.scale
	return Vector2(d.x, d.y)
