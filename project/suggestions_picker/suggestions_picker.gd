extends Spatial

var suggestions_to_index

func set_suggestions(suggestions_info):
	var names = []
	suggestions_to_index = {}
	for i in range(suggestions_info.size()):
		var suggestion = suggestions_info[i]
		var suggestion_name = str(i + 1) + ": " + suggestion["name"]
		names.append(suggestion_name)
		suggestions_to_index[suggestion_name] = i + 1
		
	$BrowserList.items = names


func _on_BrowserList_selected(value):
	get_editor().selectSuggestionAt_(suggestions_to_index[value])

func get_editor():
	if !is_inside_tree():
		return null
	for node in get_tree().get_nodes_in_group("editor"):
		return node
	return null
