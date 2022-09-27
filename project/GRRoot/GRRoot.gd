extends Node

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
	tick_update_from_squeak = 10
	create_instance_from_squeak = 11
	created_instance_from_godot = 12
	free_instance_from_squeak = 13
}

class Subscription:
	var instance: Object
	var key: String
	var callback_id: int
	var call_arguments = null
	var last_value
	
	func update():
		var current_value = instance.callv(key, call_arguments) if call_arguments else instance.get(key)
		if last_value != current_value:
			last_value = current_value
			return [callback_id, current_value]
		else:
			return null

var tcp: StreamPeerTCP
var pending_signal_handlers = []
var subscriptions = []
var session_id: int
var quit = false

func ip():
	if OS.get_cmdline_args().empty():
		return '127.0.0.1'
	else:
		return OS.get_cmdline_args()[0]

func debug_print_bytes(obj):
	var squeak_bytes = '#['
	for b in var2bytes(obj):
		squeak_bytes += str(b) + ' '
	squeak_bytes += ']'
	print(squeak_bytes)

func _ready():
	# return debug_print_bytes([])
	
	tcp = StreamPeerTCP.new()
	var error = tcp.connect_to_host(ip(), 8292)
	if error != OK:
		print("Failed to connect: " + str(error))
		return
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
	if quit:
		return
	
	# FIXME probably not gonna work like this but the idea is that we put
	# a simple marker into our stream when there's nothing supposed to be there
	# to tell godot that it should requery
	var code_changed = tcp.get_available_bytes() >= 4
	if code_changed:
		print("Hot code reload")
		tcp.get_var(true)
	
	for subscription in subscriptions:
		var update = subscription.update()
		if update:
			pending_signal_handlers.append(update)
	
	if code_changed or not pending_signal_handlers.empty() or Input.is_action_just_pressed("ui_cancel"):
		update()

func update():
	tcp.put_var([MessageType.tick_from_godot, session_id, pending_signal_handlers])
	pending_signal_handlers.clear()
	while true:
		var response = tcp.get_var(true)
		if response:
			match response[0]:
				MessageType.tick_completed_from_squeak:
					return
				MessageType.tick_update_from_squeak:
					apply_updates(response[1][0])
					bind_refs(response[1][1])
				MessageType.call_from_squeak:
					var ret = object_for(response[1]).callv(response[2], response[3])
					tcp.put_var([MessageType.response_to_call_from_godot, session_id, ret])
				MessageType.property_set_from_squeak:
					object_for(response[1]).set(response[2], response[3])
					tcp.put_var([MessageType.response_to_call_from_godot, session_id, null])
				MessageType.property_get_from_squeak:
					var ret = object_for(response[1]).get(response[2])
					tcp.put_var([MessageType.response_to_call_from_godot, session_id, ret])
				MessageType.create_instance_from_squeak:
					var ret = ClassDB.instance(response[1])
					ret.reference()
					tcp.put_var([MessageType.created_instance_from_godot, session_id, ret])
				MessageType.free_instance_from_squeak:
					response[1].unreference()
				_:
					assert(false, "unhandled message type: " + str(response[0]))

func object_for(string_or_obj_id):
	return Engine.get_singleton(string_or_obj_id) if string_or_obj_id is String else instance_from_id(string_or_obj_id.object_id)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		quit = true
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
			'clear':
				for c in get_node(root_path).get_children():
					c.queue_free()
			'add':
				var parent_path = update[1]
				var is_resource = update[2]
				var id_or_prop_name = update[3]
				var instance = create_node(update)
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
			'move':
				var nodePaths = update[1]
				var startIndex = update[2]
				for path in nodePaths:
					var child = get_node(root_path + path)
					child.get_parent().move_child(child, startIndex - 1)
					startIndex += 1
			'replace':
				var old_path = update[1]
				var is_resource = update[2]
				var id_or_prop_name = update[3]
				var instance = create_node(update)
				if is_resource:
					var target = get_node_and_resource(root_path + old_path)
					# FIXME probably wrong, always get_parent()?
					(target[1] if target[1] else target[0]).get_parent().set(id_or_prop_name, instance)
				else:
					instance.name = id_or_prop_name
					get_node(root_path + old_path).replace_by(instance)
			_:
				print("Unknown update: " + update[0])

func create_node(update):
	var gd_class_name = update[4]
	var props_dictionary = update[5]
	
	var instance = ClassDB.instance(gd_class_name)
	for key in props_dictionary.keys():
		apply_prop(instance, key, props_dictionary[key])
	
	return instance

func deserialize_args(args):
	var i = 0
	for arg in args:
		if arg is EncodedObjectAsID:
			args[i] = instance_from_id(arg.object_id)
		i += 1
	return args

func deserialize_arg(arg):
	if arg is EncodedObjectAsID:
		return instance_from_id(arg.object_id)
	return arg

func apply_prop(instance, key, value):
	if key == 'groups':
		for group in value:
			instance.add_to_group(group)
		return
	
	if key.begins_with('sqcall_'):
		key = key.substr(7)
		if not instance.has_method(key):
			print("No method named " + key + " on " + str(instance))
			return
		instance.callv(key, deserialize_args(value))
		return
	
	if key.begins_with('sqsubcall_'):
		key = key.substr(10, key.find_last('_') - 10)
		if not instance.has_method(key):
			print("No method named " + key + " on " + str(instance))
			return
		var s = Subscription.new()
		s.instance = instance
		s.key = key
		s.callback_id = value[0]
		s.call_arguments = deserialize_args(value[1])
		subscriptions.append(s)
		return
	
	if key.begins_with('sqsubscribe_'):
		key = key.substr(12)
		if not key in instance:
			print("No property named " + key + " on " + str(instance))
			return
		var s = Subscription.new()
		s.instance = instance
		s.key = key
		s.callback_id = value
		subscriptions.append(s)
		return
	
	if key.begins_with('sqmeta_'):
		key = key.substr(7)
		instance.set_meta(key, value)
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
	
	instance.set(key, deserialize_arg(value))

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
