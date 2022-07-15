class_name TSText

extends Spatial


var contents setget set_contents

var text

var id

func set_contents(aString):
	contents = aString
	text = contents

func set_block_scale(s):
	$MeshInstance.scale = s
