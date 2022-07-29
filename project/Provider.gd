extends Node

export(float, 0, 5) var block_scale = 1 setget set_block_scale
export(float, 0, 1) var child_z_offset = 0.01
export(float, 0, 1) var text_z_offset = 0.001
export(float, 0, 1) var block_thickness = 0.01

var idToBlock = {}
var currentInsertHighlights = []

var testBlock

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
		get_owner().syncLayout()
		return existing
	
#	var block = buildBlock(blockStructure)
	var block = preload("res://TSBlock/TSBlock.tscn").instance()
	block.block_scale = block_scale
	block.block_thickness = block_thickness
	block.build_from_structure(blockStructure)
	block.apply_block_scale()
	block.color = Color.white
	$"../Blocks".add_child(block)
	block.transform.origin = Vector3.ZERO
#	testBlock.get_parent().append_text("testtesttesttest")

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
			if blockStructure["highlight"].ends_with(".part"):
				block.set_flat(true)
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
			if blockStructure["contents"] == "Transcript":
				testBlock = text
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
	var blockStructure = JSON.parse(blockJson).result
	var block = idToBlock.get(int(blockStructure["id"]))
	if block != null:
		block.transform.basis = Basis()
		block.get_parent().remove_child(block)
	else:
		block = buildBlock(blockStructure)
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
	idToBlock[textBlockId].contents = content
	get_parent().syncLayout()

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
#			block.transform.origin = Vector3(blockStructure["bounds"][0] * block_scale, blockStructure["bounds"][1] * block_scale, block_thickness / 2 + text_z_offset)
			var x = Vector3(blockStructure["bounds"][0] * block_scale, blockStructure["bounds"][1] * block_scale, block_thickness / 2 + text_z_offset)
			block.transform.origin.x = x.x
			block.transform.origin.y = x.y
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

func showInsertPositions(data):
	var list = JSON.parse(data).result
	currentInsertHighlights = []
	var extra_scale = 0.005
	for position in list:
		var insertPosition = preload("res://TSInsert/TSInsert.tscn").instance()
		insertPosition.id = int(position['id'])
		insertPosition.transform.origin = Vector3(position["bounds"][0] * block_scale, position["bounds"][1] * block_scale, child_z_offset * position['depth'])
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
#	$"../Blocks".scale = Vector2.ONE * block_scale
	pass
