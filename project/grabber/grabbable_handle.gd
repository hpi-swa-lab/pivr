extends MeshInstance

# optional
export(NodePath) var grabbed_node_path

func get_grabbed_node():
	if !grabbed_node_path.is_empty():
		return get_node(grabbed_node_path)
	else:
		return get_parent()
