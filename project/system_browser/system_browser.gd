extends Spatial

var current_class

func get_editor():
	for node in get_tree().get_nodes_in_group("editor"):
		return node
	return null

func _ready():
	var itemsJson = get_editor().getCategoryStrings()
	var items = JSON.parse(itemsJson).result
	$CategoryList.items = items

func _on_CategoryList_selected(selected_category):
	Logger.log(["Catogery selected: ", selected_category])
	var itemsJson = get_editor().getClassStrings_(selected_category)
	var items = JSON.parse(itemsJson).result
	$ClassList.items = items

func _on_ClassList_selected(selected_class):
	Logger.log(["Class selected: ", selected_class])
	var itemsJson = get_editor().getMethodStrings_(selected_class)
	var items = JSON.parse(itemsJson).result
	$MethodList.items = items
	current_class = selected_class

func _on_MethodList_selected(selected_method):
	Logger.log(["Method selected: ", selected_method])
	if current_class != null:
		get_editor().openMethod_inClass_(selected_method, current_class)
