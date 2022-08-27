extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var planet_script = preload("res://scripts/Planet.st")
# var planet_script = preload("res://vrobject/VRObject.st")
var vro_scene = preload("res://vrobject/vrobject.tscn")

func createNewVRObject():
	var new_node = vro_scene.instance()
	new_node.set_script(planet_script)
	return new_node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
