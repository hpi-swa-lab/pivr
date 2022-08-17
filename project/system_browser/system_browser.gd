extends Spatial

var current_class

func get_editor():
	for node in get_tree().get_nodes_in_group("editor"):
		return node
	return null

func get_provider():
	var editor = get_editor()
	if editor == null:
		return null
	else:
		return get_editor().get_node("Provider")

func _ready():
	var itemsJson = get_editor().getCategoryStrings()
	var items = JSON.parse(itemsJson).result
	$CategoryList.items = items
	$ClassList.retrieve_item_buttons_func = funcref(self, "retrieve_item_button_func")

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

func retrieve_item_button_func(selected_class):
	if !get_editor().classIsVRObject_(selected_class):
		return []
	
	var button = preload("res://system_browser/browser_item.tscn").instance()
	button.value = ""
	button.color = Color.red
	button.dimensions = Vector2(0.04, $MethodList.item_height)
	button.connect("selected", self, "spawn_vrobject", [selected_class])
	return [button]

func spawn_vrobject(_value, vrobject_class):
	Logger.log(["Spawning vrobject ", vrobject_class])
	get_provider().spawn_vrobject(vrobject_class)
