extends Spatial

func create_node_with_script(script_path: String):
	var script = load(script_path)
	var spatial = Spatial.new()
	spatial.set_script(script)
	return spatial

func _ready():
	var new_spatial = create_node_with_script("SolarSystem.gd")
	add_child(new_spatial)


func _input(event):
	if event is InputEventMouseMotion:
		var motion = event.relative.normalized()
		$Camera.rotate_y(-motion.x * 0.1)
