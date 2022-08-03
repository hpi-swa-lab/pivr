extends Node

class_name Write

var regexes = {
	'a': 'urd',
	'b': 'durdl',
	'c': 'ldr',
	'd': 'ldru',
	'e': 'lrlr',
	'f': 'ur',
	'g': 'ldrul',
	'h': 'durd',
	'i': 'd',
	'j': 'rdl',
	'k': 'drld',
	'l': 'dr',
	'm': 'udr?ud',
	'n': 'udu',
	'o': 'drul',
	'p': 'urdl',
	'q': 'ldrl',
	'r': 'dur',
	's': 'ldrd',
	't': 'rd',
	'u': 'dru',
	'v': 'du',
	'w': 'dudu',
	'x': 'dlu',
	'y': 'dudlu?',
	'z': 'rdr',
	'1': 'u',
	'2': 'lul',
	'3': 'rlrl',
	'4': 'udl',
	'5': 'rul',
	'6': 'lu',
	'7': 'ul',
	'8': 'ulrl',
	'9': 'uld',
	'0': 'uldr',
	'{': 'ulru',
	'[': 'lur',
	'(': 'ld',
	'#': 'ududl',
	' ': 'r',
	'-': 'ldl',
	'+': 'rud',
	'*': 'rlud',
	'/': 'uru',
	'$': 'urlu',
	'%': 'urul',
	'=': 'lrl',
	'"': 'dud',
	'~': 'rur',
	',': 'lrd',
	'&': 'lurul',
	'!': 'drl',
	'_': 'dldl',
	'^': 'ud',
	'?': 'rdld',
	'`': 'lrd',
	'\'': 'udr',
	':': 'ldlr',
	'<': 'lr',
	'>': 'rl',
	'|': 'x',
	'\b': 'l',
	'\n': 'dl',
	'\t': 'x',
	'.': 'lrdu'
}

func _init():
	for key in regexes:
		var r = RegEx.new()
		r.compile(regexes[key])
		regexes[key] = r

func check_letters(directions):
	for key in regexes:
		var m = regexes[key].search(directions)
		if m and m.get_string() == directions:
			return key
	return null

func detect_chars(points, direction_func, result_func, thin_threshold):
	points = thin_points(points, thin_threshold)
	var directions = ''
	var last_p
	for p in points:
		if last_p:
			var dir = direction_func.call_func(last_p, p)
			if directions.length() < 1 or directions[directions.length() - 1] != dir:
				directions += dir
		last_p = p
	var l = check_letters(directions)
	if l:
		Logger.log("Character detected: '%s'" % l.c_escape())
		result_func.call_func(l)
	else:
		Logger.error("Character detection failed")

func thin_points(list, threshold):
	var output = [list[0]]
	for point in list:
		if output[output.size() - 1].distance_to(point) > threshold:
			output.append(point)
	return output
