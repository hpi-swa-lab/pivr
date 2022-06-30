extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var image = Image.new()
	var texture = ImageTexture.new()
	$CreateImageFormTextureNode.getTestTexture_tempImage_(texture, image)
	texture.create_from_image(image)
	$Sprite.texture = texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var image = Image.new()
	var texture = ImageTexture.new()
	$CreateImageFormTextureNode.getTestTexture_tempImage_(texture, image)
	texture.create_from_image(image)
	$Sprite.texture = texture
