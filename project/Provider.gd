extends Node

export(float, 0, 5) var block_scale = 1 setget set_block_scale
export(float, 0, 1) var child_z_offset = 0.03
export(float, 0, 1) var text_z_offset = 0.001
export(float, 0, 1) var block_thickness = 0.03

var idToBlock = {}

func set_block_scale(value):
	block_scale = value
#	if $"../Blocks" != null:
#		$"../Blocks".scale = Vector2.ONE * block_scale

func test_func():
	print("Hellol")

func doOpenEditorMorphCommand(structureOfBlockJson: String):
	var blockStructure = JSON.parse(structureOfBlockJson).result
	var id = int(blockStructure['id'])
	if id in idToBlock:
		var existing = idToBlock[id]
		$"../Blocks".add_child(existing)
		# existing.transform.origin = Vector3.ZERO
		get_owner().syncLayout()
		return existing
	
	var block = buildBlock(blockStructure)
	block.color = Color.white
	$"../Blocks".add_child(block)
	block.transform.origin = Vector3.ZERO

func buildBlock(blockStructure):
	match blockStructure['class']:
		'block':
			var block = preload("res://TSBlock/TSBlock.tscn").instance()
			block.id = int(blockStructure['id'])
			# bounds: [left, top, width, height]
			block.transform.origin = Vector3(blockStructure["bounds"][0] * block_scale, blockStructure["bounds"][1] * block_scale, child_z_offset)
			block.set_block_scale(Vector3(blockStructure["bounds"][2] * block_scale, blockStructure["bounds"][3] * block_scale, block_thickness))
			for child in blockStructure['children']:
				var childBlock = buildBlock(child)
				if childBlock:
					addChildBlock(childBlock, block)
			idToBlock[block.id] = block
			block.connect("gui_input", get_parent(), "blockInput_on_", [block.id])
			return block
		'text':
			var text = preload("res://TSText/TSText.tscn").instance()
			text.id = int(blockStructure['id'])
			text.contents = blockStructure['contents']
			text.color = Color(blockStructure["color"])
			text.transform.origin = Vector3(blockStructure["bounds"][0] * block_scale, blockStructure["bounds"][1] * block_scale, block_thickness / 2 + text_z_offset)
			text.set_block_scale(Vector3(blockStructure["bounds"][2] * block_scale, blockStructure["bounds"][3] * block_scale, block_thickness))
#			text.add_color_override("font_color", Color(blockStructure['color']))
			idToBlock[text.id] = text
			return text
		'hardLineBreak':
			return null
		_:
			print("unknown block class: " + blockStructure['class'])
			return null

func addChildBlock(child, parent):
	parent.add_child(child)
	child.transform.origin.x = child.transform.origin.x - parent.transform.origin.x + (child.get_dimensions().x - parent.get_dimensions().x) / 2
	child.transform.origin.y = child.transform.origin.y - parent.transform.origin.y + (child.get_dimensions().y - parent.get_dimensions().y) / 2
	child.transform.origin.y *= -1

func insertNewBlock(blockJson, index, containerId):
	var container = idToBlock[containerId]
	var block = buildBlock(JSON.parse(blockJson).result)
	addChildBlock(block, container)
	container.move_child(block, index - 1)
	get_owner().syncLayout()

func get_editor():
	return get_parent()

func removeBlockWithId(id):
	var block = idToBlock[id]
	block.get_parent().remove_child(block)
	get_parent().syncLayout()

func setTextBlockContent(content, textBlockId):
	idToBlock[textBlockId].text = content

var root_block_positions
func syncLayout(structuresJson):
	root_block_positions = {}
	var structures = JSON.parse(structuresJson).result
	for id in structures:
		var blockStructure = structures[id]
		var block = idToBlock[int(id)]
		var blockClass = blockStructure["class"]
		if blockClass == "block":
			if block.is_root_block():
				root_block_positions[block] = block.global_transform.origin
			block.transform.origin = Vector3(blockStructure["bounds"][0] * block_scale, blockStructure["bounds"][1] * block_scale, child_z_offset)
			block.set_block_scale(Vector3(blockStructure["bounds"][2] * block_scale, blockStructure["bounds"][3] * block_scale, block_thickness))
		elif blockClass == "text":
			block.transform.origin = Vector3(blockStructure["bounds"][0] * block_scale, blockStructure["bounds"][1] * block_scale, block_thickness / 2 + text_z_offset)
			block.set_block_scale(Vector3(blockStructure["bounds"][2] * block_scale, blockStructure["bounds"][3] * block_scale, block_thickness))
	for block in $"../Blocks".get_children():
		correctChildPositions(block)
	for block in root_block_positions:
		block.global_transform.origin = root_block_positions[block]

func correctChildPositions(block):
	for child in block.get_block_children():
		correctChildPositions(child)
		child.transform.origin.x = child.transform.origin.x - block.transform.origin.x + (child.get_dimensions().x - block.get_dimensions().x) / 2
		child.transform.origin.y = child.transform.origin.y - block.transform.origin.y + (child.get_dimensions().y - block.get_dimensions().y) / 2
		child.transform.origin.y *= -1

func _ready():
#	$"../Blocks".scale = Vector2.ONE * block_scale
	pass
