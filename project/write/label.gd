extends Spatial

var text  = '' setget set_text

func set_text(val):
	text = val
	$Viewport/Label.text = val
	$Viewport.size = $Viewport/Label.get_font("font").get_string_size(val)
	
	# recalc layout
	$Sprite3D.pixel_size = $Sprite3D.pixel_size
	$Sprite3D.visible = val.length() > 0
