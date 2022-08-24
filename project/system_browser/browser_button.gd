tool

extends MeshInstance

signal pressed

export(Texture) var texture setget set_texture

var shown = true setget set_shown

func set_shown(value):
	shown = value
	visible = shown
	$Area/CollisionShape.disabled = !shown

func resize_sprite():
	var size = Vector2(mesh.size.x, mesh.size.y) / $Sprite3D.texture.get_size()
	$Sprite3D.scale = Vector3(size.x, size.y, 1)

func set_texture(value):
	texture = value
	$Sprite3D.texture = texture
	resize_sprite()

func get_height():
	return mesh.size.y

func is_selectable():
	return true

func select_at(_global_point):
	emit_signal("pressed")

func _ready():
	resize_sprite()

func _process(_delta):
	if Engine.editor_hint:
		pass
#		resize_sprite()
