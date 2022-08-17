extends Spatial

export(Array, String) var items = [] setget set_items
export(int) var window_size = 5
export(float) var item_width = 0.2
export(float) var item_height = 0.1
export(float) var item_bottom_margin = 0.01

var window_position = 0 setget set_window_position

var retrieve_item_buttons_func

signal selected

func set_items(value):
	items = value
	regenerate_list()

func regenerate_list():
	set_window_position(0)

func set_window_position(value):
	window_position = value
	
	for child in $Items.get_children():
		child.queue_free()
	
	var y_offset = 0
	var end = min(items.size(), window_position + window_size)
	for i in range(window_position, end):
		var item_node = preload("res://system_browser/browser_item.tscn").instance()
		item_node.retrieve_item_buttons_func = retrieve_item_buttons_func
		item_node.value = items[i]
		item_node.set_dimensions(Vector2(item_width, item_height))
		item_node.transform.origin.y = y_offset
		y_offset -= item_height + item_bottom_margin
		item_node.connect("selected", self, "on_item_selected")
		$Items.add_child(item_node)
	
	$BrowserButtonUp.transform.origin.y = ($BrowserButtonUp.get_height() + item_height) / 2 + item_bottom_margin
	$BrowserButtonDown.transform.origin.y = y_offset - ($BrowserButtonDown.get_height() - item_height) / 2

func on_item_selected(value):
	emit_signal("selected", value)

func _ready():
	regenerate_list()

func _on_button_pressed(is_down):
	var new_window_position
	if is_down:
		new_window_position = clamp(items.size() - window_size, 0, window_position + window_size)
	else:
		new_window_position = max(window_position - window_size, 0)
	set_window_position(new_window_position)
