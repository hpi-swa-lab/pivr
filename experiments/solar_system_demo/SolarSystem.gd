extends Spatial

var planet_script = preload("res://Planet.gd")

func random_color():
	var r = rand_range(0, 1)
	var g = rand_range(0, 1)
	var b = rand_range(0, 1)
	return Color(r, g, b)

func create_planet_node():
	var spatial = Spatial.new()
	spatial.set_script(planet_script)
	return spatial

func _init():
	for i in range(10):
		var new_planet = create_planet_node()
		new_planet.orbit = 10.0 * i
		new_planet.velocity = rand_range(2, 20)
		new_planet.color = random_color()
		new_planet.radius = rand_range(1, 4)
		add_child(new_planet)
