extends Spatial

var color = Color.white setget set_color
var value: String setget set_value
var dimensions = Vector2.ONE setget set_dimensions
var retrieve_item_buttons_func
var button_margin = 0.01

signal selected

func set_value(v):
	value = v
	$Label3D.text = value
	$Label3D.pixel_size = 1 / $Label3D.font.get_height()
	fit_text()
	update_text_position()
	update_buttons()

func set_color(value):
	color = value
	$Scaled/MeshInstance.get_surface_material(0).albedo_color = color

func set_dimensions(value):
	dimensions = value
	
	$Scaled.scale.x = dimensions.x
	$Scaled.scale.y = dimensions.y

	$Label3D.scale = Vector3.ONE * dimensions.y
	fit_text()
	update_text_position()
	update_buttons_layout()

func fit_text():
	if in_world_width(value) <= dimensions.x:
		$Label3D.text = value
		return
	
	var dots = '...'
	if in_world_width(dots) > dimensions.x:
		Logger.error("dots are larger than item width!")
		$Label3D.text = dots
		return
	
	var display_value = value.left(value.length() - 1)
	# cool kids would use binary search here
	while in_world_width(display_value + dots) > dimensions.x:
		display_value = display_value.left(display_value.length() - 1)
	
	$Label3D.text = display_value + dots

# we set the pixel size such that, without any scaling applied, the height of the rendered text is 1
# this function gives us the corresponding width
func in_world_width(string):
	var string_size = $Label3D.font.get_string_size(string)
	return (string_size.x / $Label3D.font.get_height()) * $Label3D.scale.y

func update_text_position():
#	var pos = (dimensions - $TextQuad.get_dimensions()) / 2
#	pos.x *= -1
#	$TextQuad.transform.origin = Vector3(pos.x, pos.y, $TextQuad.transform.origin.z)
	$Label3D.transform.origin.x = -dimensions.x / 2

func update_buttons():
	if retrieve_item_buttons_func == null:
		return
	
	var buttons = retrieve_item_buttons_func.call_func(value)
	for button in buttons:
		$Buttons.add_child(button)
	update_buttons_layout()

func update_buttons_layout():
	var offset = dimensions.x / 2 + button_margin
	for button in $Buttons.get_children():
		button.transform.origin.x = offset + button.dimensions.x / 2
		offset += button.dimensions.x + button_margin

func is_selectable():
	return true

func select_at(_global_point):
	emit_signal("selected", value)
