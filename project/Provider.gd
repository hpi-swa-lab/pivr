extends Node

export(float, 0, 5) var block_scale = 1 setget set_block_scale
export(float, 0, 1) var child_z_offset = 0.5
export(float, 0, 1) var block_thickness = 0.5

var idToBlock = {}

func set_block_scale(value):
	block_scale = value
#	if $"../Blocks" != null:
#		$"../Blocks".scale = Vector2.ONE * block_scale

func test_func():
	print("Hellol")

func doOpenEditorMorphCommand(structureOfBlockJson: String):
	var blockStructure = JSON.parse(structureOfBlockJson).result
	var block = buildBlock(blockStructure)
	$"../Blocks".add_child(block)
#	block.rect_position.x = 0
#	block.rect_position.y = 0
#	$"../Blocks".position = -block.rect_position

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
			text.transform.origin = Vector3(blockStructure["bounds"][0] * block_scale, blockStructure["bounds"][1] * block_scale, child_z_offset)
			text.set_block_scale(Vector3(0.01, 0.01, block_thickness))
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
	child.transform.origin.x -= parent.transform.origin.x
	child.transform.origin.y -= parent.transform.origin.y

func insertNewBlock(blockJson, index, containerId):
	var container = idToBlock[containerId]
	var block = buildBlock(JSON.parse(blockJson).result)
	addChildBlock(block, container)
	container.move_child(block, index - 1)
	get_owner().syncLayout()

func removeBlockWithId(id):
	var block = idToBlock[id]
	block.get_parent().remove_child(block)
	get_parent().syncLayout()

func setTextBlockContent(content, textBlockId):
	idToBlock[textBlockId].text = content

func syncLayout(structuresJson):
	var structures = JSON.parse(structuresJson).result
	for id in structures:
		var blockStructure = structures[id]
		var block = idToBlock[int(id)]
		var blockClass = blockStructure["class"]
		if blockClass == "block" or blockClass == "text":
			block.rect_position.x = blockStructure["bounds"][0]
			block.rect_position.y = blockStructure["bounds"][1]
		if blockClass == "block":
			block.rect_size.x = blockStructure["bounds"][2]
			block.rect_size.y = blockStructure["bounds"][3]
	for block in $"../Blocks".get_children():
		correctChildPositions(block)

func correctChildPositions(block):
	for child in block.get_children():
		correctChildPositions(child)
		child.rect_position -= block.rect_position

func _ready():
#	$"../Blocks".scale = Vector2.ONE * block_scale
	pass
