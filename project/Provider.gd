extends Node

export(float, 0, 5) var block_scale = 0.0008 setget set_block_scale
export(float, 0, 1) var child_z_offset = 0.01
export(float, 0, 1) var text_z_offset = 0.001
export(float, 0, 1) var block_thickness = 0.003

var idToBlock = {}
var currentInsertHighlights = []

var testBlock

func set_block_scale(value):
	block_scale = value

func test_func():
	print("Hellol")

func syncMultipleLayouts(structuresJson):
	var structures = JSON.parse(structuresJson).result
	for structure in structures:
		var id = int(structure["id"])
		Logger.log(["temp: attempting to layout ", id])
		var block = idToBlock.get(id)
		if block == null:
			Logger.error(["Attempted to sync layout for id ", id, " that wasn't registered"])
		else:
			block.sync_to_layout_structure(structure)

func syncLayoutForAll():
	for child in $"../Blocks".get_children():
		child.sync_layout()
	
	var cursor_info_json = get_editor().getCursorInfo()
	if cursor_info_json != null:
		var cursor_info = JSON.parse(cursor_info_json).result
		var text = idToBlock[int(cursor_info["textId"])]
		text.add_cursor_at_index(int(cursor_info["index"]) - 1)

func doOpenEditorMorphCommand(structureOfBlockJson: String):
	var blockStructure = JSON.parse(structureOfBlockJson).result
	var id = int(blockStructure['id']) 
	if id in idToBlock:
		var existing = idToBlock[id]
		$"../Blocks".add_child(existing)
		return existing
	
	var block = preload("res://TSBlock/TSBlock.tscn").instance()
	block.block_scale = block_scale
	block.block_thickness = block_thickness
	block.build_from_structure(blockStructure)
	block.apply_block_scale()
	block.color = Color.white
	$"../Blocks".add_child(block)
	block.register_self_and_children_if_necessary()
	block.transform.origin = Vector3.ZERO

func addChildBlock(child, parent):
	parent.add_child(child)
	child.transform.origin.x = child.transform.origin.x - parent.transform.origin.x + (child.get_dimensions().x - parent.get_dimensions().x) / 2
	child.transform.origin.y = child.transform.origin.y - parent.transform.origin.y + (child.get_dimensions().y - parent.get_dimensions().y) / 2
	child.transform.origin.y *= -1

func insertNewBlock(structure_json, index, container_id):
	var container = idToBlock[container_id]
	var structure = JSON.parse(structure_json).result
	var block = idToBlock.get(int(structure["id"]))
	if block == null:
		block = preload("res://TSBlock/TSBlock.tscn").instance()
		block.build_from_structure(structure)
	container.add_child_block(block, index - 1)
	block.register_self_and_children_if_necessary()

func get_editor():
	return get_parent()

func removeBlockWithId(id):
	var block = idToBlock[id]
	if block.is_root_block():
		$"../Blocks".remove_child(block)
	else:
		var parent_block = block.get_parent_block()
		parent_block.remove_child_block(block)

func setTextBlockContent(content, textBlockId):
	idToBlock[textBlockId].contents = content

func syncLayout(structure_json):
	var structure = JSON.parse(structure_json).result
	idToBlock[int(structure["id"])].sync_to_layout_structure(structure)

var root_block_positions
func syncLayout_(structuresJson):
	print("SYNCING LAYOUT")

func correctChildPositions(block):
	for child in block.get_block_children():
		correctChildPositions(child)
		child.transform.origin.x = child.transform.origin.x - block.transform.origin.x + (child.get_dimensions().x - block.get_dimensions().x) / 2
		child.transform.origin.y = child.transform.origin.y - block.transform.origin.y + (child.get_dimensions().y - block.get_dimensions().y) / 2
		child.transform.origin.y *= -1

func showInsertPositions(data):
	var list = JSON.parse(data).result
	currentInsertHighlights = []
	var extra_scale = 0.005
	for position in list:
		var insertPosition = preload("res://TSInsert/TSInsert.tscn").instance()
		insertPosition.id = int(position['id'])
		insertPosition.transform.origin = Vector3(position["bounds"][0] * block_scale, position["bounds"][1] * block_scale, block_thickness * position['depth'])
		insertPosition.set_block_scale(Vector3(position["bounds"][2] * block_scale, position["bounds"][3] * block_scale, block_thickness))
		
		var containerBlock = idToBlock[int(position['floatId'])]
		containerBlock.add_child(insertPosition)
		
		insertPosition.transform.origin.x += (insertPosition.get_dimensions().x - containerBlock.get_dimensions().x) / 2
		insertPosition.transform.origin.y += (insertPosition.get_dimensions().y - containerBlock.get_dimensions().y) / 2
		insertPosition.transform.origin.y *= -1
		
		# now that is properly positioned, expand from center to enlarge
		insertPosition.set_block_scale(Vector3(position["bounds"][2] * block_scale + extra_scale, position["bounds"][3] * block_scale + extra_scale, block_thickness + extra_scale))
		
		currentInsertHighlights.append(insertPosition)

func clearInsertHighlights():
	for h in currentInsertHighlights:
		h.queue_free()

func _ready():
	pass
