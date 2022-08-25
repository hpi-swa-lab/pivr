extends Area

func get_grabbed_node():
	return get_parent().get_grabbed_node()
