class_name TSText

extends Spatial

var contents setget set_contents
var color setget set_color

var text

var id

func set_color(value):
	color = value
	$Viewport/Label.add_color_override("font_color", color)

func set_contents(aString):
	contents = aString
	text = contents
	$Viewport/Label.text = contents
	if get_tree() != null:
		yield(get_tree(), "idle_frame")
		$Viewport.size = $Viewport/Label.rect_size

func set_block_scale(s):
	$MeshInstance.scale = s

func get_dimensions():
	return $MeshInstance.scale
	
func _ready():
	$Viewport.size = $Viewport/Label.rect_size
