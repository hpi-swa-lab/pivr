extends Control

var count = 0

func set_rect_size(size):
	rect_size = size
	$Content.rect_size = Vector2(size.x, size.y - $Content.rect_position.y)

func on_log_occurred(message, type):
	var time = OS.get_datetime()
	var color
	match type:
		Logger.MessageType.ERROR:
			color = "#ff4b4b"
		Logger.MessageType.LOG, _:
			color = "#666666"
	
	$Content.append_bbcode("[color=%s][%02d:%02d:%02d][/color] %s\n" % [color, time["hour"], time["minute"], time["second"], message])
	count += 1

func _ready():
	Logger.connect("log_occurred", self, "on_log_occurred")

func _process(_delta):
	var time = OS.get_datetime()
	$Header/Time.text = "[%02d:%02d:%02d]" % [time["hour"], time["minute"], time["second"]]
