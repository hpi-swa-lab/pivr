extends Node

var pending_signal_handlers = []

const root_path = '/root/DworphicWorld/'
enum MessageType {
	tick_from_godot = 0
	tick_completed_from_squeak = 1
	call_from_squeak = 2
	response_to_call_from_godot = 3
	initialize_session_from_godot = 4
	initialized_session_from_squeak = 5
	quit_from_godot = 6
	property_set_from_squeak = 7
	property_get_from_squeak = 8
	bind_refs_from_godot = 9
}

var tcp: StreamPeerTCP

var session_id

func ip():
	if OS.get_cmdline_args().empty():
		return '127.0.0.1'
	else:
		return OS.get_cmdline_args()[0]

func _ready():
	tcp = StreamPeerTCP.new()
	var error = tcp.connect_to_host(ip(), 8292)
	if error != OK:
		print("Failed to connect: " + str(error))
	while tcp.get_status() != 2:
		if tcp.get_status() == 3:
			print("Failed to connect")
			return
	tcp.set_no_delay(true)
	tcp.put_var([MessageType.initialize_session_from_godot])
	var response = tcp.get_var(true)
	assert(response[0] == MessageType.initialized_session_from_squeak)
	session_id = response[1]
	update()

func _process(_delta):
	if not pending_signal_handlers.empty() or Input.is_action_just_pressed("ui_cancel"):
		update()

func update():
	tcp.put_var([MessageType.tick_from_godot, session_id, pending_signal_handlers])
	pending_signal_handlers.clear()
	while true:
		var response = tcp.get_var(true)
		if response:
			match response[0]:
				MessageType.tick_completed_from_squeak:
					apply_updates(response[1][0])
					bind_refs(response[1][1])
					return
				MessageType.call_from_squeak:
					var ret = object_for(response[1]).callv(response[2], response[3])
					tcp.put_var([MessageType.response_to_call_from_godot, session_id, ret])
				MessageType.property_set_from_squeak:
					object_for(response[1]).set(response[2], response[3])
					tcp.put_var([MessageType.response_to_call_from_godot, session_id, null])
				MessageType.property_get_from_squeak:
					var ret = object_for(response[1]).get(response[2])
					tcp.put_var([MessageType.response_to_call_from_godot, session_id, ret])

func object_for(string_or_obj_id):
	return Engine.get_singleton(string_or_obj_id) if string_or_obj_id is String else instance_from_id(string_or_obj_id.object_id)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		tcp.put_var([MessageType.quit_from_godot, session_id])
		get_tree().quit()

func bind_refs(refs):
	if refs.empty():
		return
	var response = []
	for ref in refs:
		var target = get_node_and_resource(root_path + ref)
		response.append(target[1] if target[1] else target[0])
	# TODO: only send if objectIds actually changed
	tcp.put_var([MessageType.bind_refs_from_godot, session_id, response])

func apply_updates(list):
	for update in list:
		match update[0]:
			'add':
				var parent_path = update[1]
				var is_resource = update[2]
				var id_or_prop_name = update[3]
				var gd_class_name = update[4]
				var props_dictionary = update[5]
				
				# FIXME seems like ClassDB find custom classes? if so, we will need to maintain our own list somewhere
				var instance = GRVRRoot.new() if gd_class_name == "GRVRRoot" else ClassDB.instance(gd_class_name)
				for key in props_dictionary.keys():
					apply_prop(instance, key, props_dictionary[key])
				
				if is_resource:
					var target = get_node_and_resource(root_path + parent_path)
					(target[1] if target[1] else target[0]).set(id_or_prop_name, instance)
				else:
					instance.name = id_or_prop_name
					get_node(root_path + parent_path).add_child(instance)
			'update':
				var path = update[1]
				var key = update[2]
				var value = update[3]
				var target = get_node_and_resource(root_path + path)
				apply_prop(target[1] if target[1] else target[0], key, value)
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
func note_signal3(arg1, arg2, arg3, callback_id):
	pending_signal_handlers.append([callback_id, arg1, arg2, arg3])
func note_signal4(arg1, arg2, arg3, arg4, callback_id):
	pending_signal_handlers.append([callback_id, arg1, arg2, arg3, arg4])
