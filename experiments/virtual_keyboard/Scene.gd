extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var keyboard = $Virtual_Keyboard
var listen_to_keyboard = false

# Called when the node enters the scene tree for the first time.
func _ready():
	print(ARVRServer.get_interfaces())
	var VR = ARVRServer.find_interface("OpenXR")
	if VR and VR.initialize():
		get_viewport().arvr = true

		OS.vsync_enabled = false
		Engine.target_fps = 90


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventKey and event.is_pressed() and listen_to_keyboard:
		$Label3D.text += char(event.unicode)

func _on_LeftHandController_button_pressed(button):
	if button == 3:
		if keyboard.visible:
			keyboard.hide()
			listen_to_keyboard = false
		else:
			keyboard.show()
			keyboard.translation = $FPController/LeftHandController.translation
			keyboard.rotation.x = deg2rad(-30)
			keyboard.rotation.y = $FPController/LeftHandController.rotation.y
			listen_to_keyboard = true
