extends Spatial

export var horizontal_resolution = 300

func _ready():
	var quad_size = $Quad.mesh.size
	var ratio = quad_size.y / quad_size.x
	var size = Vector2(horizontal_resolution, horizontal_resolution * ratio)
	$LogViewport.size = size
	$LogViewport/Log.set_rect_size(size)

func _on_button_pressed(button):
	if button == JOY_BUTTON_1:
		visible = true

func _on_button_release(button):
	if button == JOY_BUTTON_1:
		visible = false
