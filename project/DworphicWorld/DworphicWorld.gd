extends Node

var pending_signal_handlers = []

const root_path = '/root/DworphicWorld/'
const USE_TCP = false
enum MessageType {
	tick_from_godot = 0
	tick_completed_from_squeak = 1
	call_from_squeak = 2
	response_to_call_from_godot = 3
}

var http: HTTPRequest
var tcp: StreamPeerTCP

func _ready():
	if USE_TCP:
		tcp = StreamPeerTCP.new()
		var error = tcp.connect_to_host('127.0.0.1', 8292)
		if error != OK:
			print(error)
	else:
		http = HTTPRequest.new()
		add_child(http)
		http.connect("request_completed", self, "_on_update_arrived")
	update(true)

func _process(_delta):
	if not pending_signal_handlers.empty():
		update()

func update(init = false):
	if USE_TCP:
		tcp.put_var([MessageType.tick_from_godot, pending_signal_handlers])
		pending_signal_handlers.clear()
		while true:
			var response = tcp.get_var(true)
			if response:
				match response[0]:
					MessageType.tick_completed_from_squeak:
						apply_updates(response[1])
						return
					MessageType.call_from_squeak:
						var ret = instance_from_id(response[1].object_id).callv(response[2], response[3])
						tcp.put_var(MessageType.response_to_call_from_godot, ret)
	else:
		http.request(
			"http://localhost:8000/" + ("init" if init else "update"),
			["Content-Type: application/json"],
			false,
			HTTPClient.METHOD_POST,
			JSON.print(pending_signal_handlers))
		pending_signal_handlers.clear()

func _on_update_arrived(_result, response_code, _headers, body):
	if response_code == 200:
		apply_updates(JSON.parse(body.get_string_from_utf8()).result)

func apply_updates(json):
	for update in json:
		match update[0]:
			'add':
				var parent_path = update[1]
				var is_resource = update[2]
				var id_or_prop_name = update[3]
				var gd_class_name = update[4]
				var props_dictionary = update[5]
				
				var instance = ClassDB.instance(gd_class_name)
				for key in props_dictionary.keys():
					apply_prop(instance, key, props_dictionary[key])
				
				if is_resource:
					get_node_and_resource(root_path + parent_path)[0].set(id_or_prop_name, instance)
				else:
					instance.name = id_or_prop_name
					get_node(root_path + parent_path).add_child(instance)
			'update':
				var path = update[1]
				var key = update[2]
				var value = update[3]
				apply_prop(get_node_and_resource(root_path + path)[0], key, value)
			'delete':
				get_node(root_path + update[1]).queue_free()
			_:
				print("Unknown update: " + update[0])

func apply_prop(instance, key, value):
	if key == 'groups':
		for group in value:
			instance.add_to_group(group)
		return
	
	if instance.has_signal(key):
		for s in instance.get_signal_list():
			if s['name'] == key:
				var handler_name = 'note_signal' + str(len(s['args']))
				if not instance.get_signal_connection_list(key).empty():
					instance.disconnect(key, self, handler_name)
				instance.connect(key, self, handler_name, [value])
		return
	
	if not key in instance:
		print("No property named " + key + " on " + str(instance))
		return
	
	instance.set(key, value)

# no variadic arguments, so have one signature per needed count of arguments...
func note_signal0(callback_id):
	pending_signal_handlers.append([callback_id])
func note_signal1(arg1, callback_id):
	pending_signal_handlers.append([callback_id, arg1])
func note_signal2(arg1, arg2, callback_id):
	pending_signal_handlers.append([callback_id, arg1, arg2])
