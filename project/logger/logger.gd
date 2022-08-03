extends Node

signal log_occurred

export var output_enabled = true

func log(values):
	var s
	if typeof(values) != TYPE_ARRAY:
		s = str(values)
	else:
		s = ""
		for value in values:
			s += str(value) + " "
	
	if output_enabled:
		print(s)
	
	emit_signal("log_occurred", s)
