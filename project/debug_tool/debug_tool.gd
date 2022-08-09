extends Spatial

export(bool) var active = true

func get_editor():
	for node in get_tree().get_nodes_in_group("editor"):
		return node
	return null

func _on_button_pressed(button):
	if !active:
		return
	
#	match button:
#		JOY_BUTTON_7:
#			Logger.log("Compiling method...")
#			var success = get_editor().tempCompileMethod()
#			if success:
#				Logger.log("Compiling successful!")
#			else:
#				Logger.error("Compiling failed :(")
