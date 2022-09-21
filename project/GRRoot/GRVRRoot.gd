extends Spatial
class_name GRVRRoot

func _ready():
	var interface = ARVRServer.find_interface("OpenXR")
	if interface and interface.initialize():
		get_viewport().hdr = false
		
		get_viewport().arvr = true
		OS.vsync_enabled = false
		Engine.iterations_per_second = 90
