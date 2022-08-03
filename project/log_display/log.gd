extends Control

var count = 0

func set_rect_size(size):
	rect_size = size
	$Content.rect_size = Vector2(size.x, size.y - $Content.rect_position.y)

func on_log_occurred(message):
	var time = OS.get_datetime()
	$Content.text += "[%02d:%02d:%02d] %s\n" % [time["hour"], time["minute"], time["second"], message]
	count += 1

func _ready():
	Logger.connect("log_occurred", self, "on_log_occurred")

func _process(_delta):
	var time = OS.get_datetime()
	$Header/Time.text = "[%02d:%02d:%02d]" % [time["hour"], time["minute"], time["second"]]
