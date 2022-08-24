extends Spatial

export(Color) var color setget set_color
export(float) var orbit = 10 setget set_orbit
export(float) var velocity = 10
export(float) var radius = 1.0

var mesh_instance

func set_orbit(new_orbit: float):
	orbit = new_orbit
	translation.x = orbit
	translation.y = 0

func set_color(new_color: Color):
	color = new_color
	var mesh = mesh_instance.get_mesh()
	var material = mesh.get_material()
	if not material:
		material = SpatialMaterial.new()
	material.albedo_color = new_color
	mesh.material = material

func _init():
	mesh_instance = MeshInstance.new()
	var mesh = SphereMesh.new()
	mesh.radius = radius
	mesh_instance.set_mesh(mesh)
	add_child(mesh_instance)


func _process(delta):
	var direction = translation.rotated(Vector3.UP, deg2rad(90)).normalized()
	translate(direction * delta * velocity)
