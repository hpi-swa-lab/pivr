extends Spatial

export(String) var filter
export var hideable = true
export var horizontal_resolution = 300
export(String) var title = ""

func _ready():
	var quad_size = $Quad.mesh.size
	var ratio = quad_size.y / quad_size.x
	var size = Vector2(horizontal_resolution, horizontal_resolution * ratio)
	$LogViewport.size = size
	$LogViewport/Log.set_rect_size(size)
	$LogViewport/Log.filter = filter
	if title != "":
		$LogViewport/Log.set_title(title)

func _on_button_pressed(button):
	if hideable and button == JOY_BUTTON_1:
		visible = true

func _on_button_release(button):
	if hideable and button == JOY_BUTTON_1:
		visible = false
