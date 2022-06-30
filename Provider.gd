extends Node

func test_func():
	print("Hellol")

func doOpenEditorMorphCommand(structureOfBlockJson: String):
	var blockStructure = JSON.parse(structureOfBlockJson).result
	var block = buildBlock(blockStructure)
	get_parent().add_child(block)
	block.rect_position.x = 0
	block.rect_position.y = 0

func buildBlock(blockStructure):
	match blockStructure['class']:
		'block':
			var block = preload("res://TSBlock/TSBlock.tscn").instance()
			block.id = blockStructure['id']
			block.rect_position.x = blockStructure['bounds']['x']
			block.rect_position.y = blockStructure['bounds']['y']
			block.rect_size.x = blockStructure['bounds']['width']
			block.rect_size.y = blockStructure['bounds']['height']
			for child in blockStructure['children']:
				var childBlock = buildBlock(child)
				if childBlock:
					block.add_child(childBlock)
					childBlock.rect_position -= block.rect_position
			return block
		'text':
			var text = preload("res://TSText/TSText.tscn").instance()
			text.contents = blockStructure['contents']
			text.rect_position.x = blockStructure['bounds']['x']
			text.rect_position.y = blockStructure['bounds']['y']
			text.add_color_override("font_color", Color(blockStructure['color']))
			return text
		'hardLineBreak':
			return null
		_:
			print("unknown block class: " + blockStructure['class'])
			return null
