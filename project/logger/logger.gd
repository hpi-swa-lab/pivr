extends Node

enum MessageType {
	LOG,
	ERROR
}

signal log_occurred

export var output_enabled = true

func new_message(values, type):
	var s
	if typeof(values) != TYPE_ARRAY:
		s = str(values)
	else:
		s = ""
		for value in values:
			s += str(value) + " "
	
	if output_enabled:
		print(s)
	
	emit_signal("log_occurred", s, type)

func log(values):
	new_message(values, MessageType.LOG)

func error(values):
	new_message(values, MessageType.ERROR)
