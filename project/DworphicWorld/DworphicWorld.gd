extends Spatial

var pending_signal_handlers = []

const root_path = '/root/DworphicWorld/'

func _ready():
	var j = [["add","",false,"1027","Camera",{"current":true}],["add","",false,"1028","Area",{"button_pressed":"1029","area_entered":"1030","area_exited":"1031","button_released":"1032"}],["add","\/1028",false,"1033","CollisionShape",{}],["add","\/1028\/1033",true,"shape","SphereShape",{"radius":0.002,"margin":0.001}],["add","",false,"1034","Spatial",{"name":"TSBlock","groups":["tsblock"]}],["add","\/1034",false,"1035","Spatial",{"scale":[0.0,0.0,0.019999999552965164],"name":"Scaled"}],["add","\/1034\/1035",false,"1036","MeshInstance",{"mesh":[{"extents":[0.5,0.5,0.5],"margin":0.001}]}],["add","\/1034",false,"1037","Spatial",{"name":"Blocks"}],["add","\/1034\/1037",false,"1038","Spatial",{"name":"TSBlock","groups":["tsblock"]}],["add","\/1034\/1037\/1038",false,"1039","Spatial",{"scale":[4.199999809265137,4.199999809265137,0.019999999552965164],"name":"Scaled"}],["add","\/1034\/1037\/1038\/1039",false,"1040","MeshInstance",{"mesh":[{"extents":[0.5,0.5,0.5],"margin":0.001}]}],["add","\/1034\/1037\/1038",false,"1041","Spatial",{"name":"Blocks"}],["add","\/1034\/1037\/1038\/1041",false,"1042","Spatial",{"name":"TSBlock","groups":["tsblock"]}],["add","\/1034\/1037\/1038\/1041\/1042",false,"1043","Spatial",{"scale":[4.800000190734863,4.800000190734863,0.019999999552965164],"name":"Scaled"}],["add","\/1034\/1037\/1038\/1041\/1042\/1043",false,"1044","MeshInstance",{"mesh":[{"extents":[0.5,0.5,0.5],"margin":0.001}]}],["add","\/1034\/1037\/1038\/1041\/1042",false,"1045","Spatial",{"name":"Blocks"}],["add","\/1034\/1037\/1038\/1041\/1042",false,"1046","Area",{"groups":["grabbable"],"scale":[4.800000190734863,4.800000190734863,0.019999999552965164],"collision_layer":3}],["add","\/1034\/1037\/1038\/1041\/1042\/1046",false,"1047","CollisionShape",{}],["add","\/1034\/1037\/1038\/1041",false,"1048","Spatial",{"name":"TSBlock","groups":["tsblock"]}],["add","\/1034\/1037\/1038\/1041\/1048",false,"1049","Spatial",{"scale":[12.600000381469727,4.800000190734863,0.019999999552965164],"name":"Scaled"}],["add","\/1034\/1037\/1038\/1041\/1048\/1049",false,"1050","MeshInstance",{"mesh":[{"extents":[0.5,0.5,0.5],"margin":0.001}]}],["add","\/1034\/1037\/1038\/1041\/1048",false,"1051","Spatial",{"name":"Blocks"}],["add","\/1034\/1037\/1038\/1041\/1048",false,"1052","Area",{"groups":["grabbable"],"scale":[12.600000381469727,4.800000190734863,0.019999999552965164],"collision_layer":3}],["add","\/1034\/1037\/1038\/1041\/1048\/1052",false,"1053","CollisionShape",{}],["add","\/1034\/1037\/1038",false,"1054","Area",{"groups":["grabbable"],"scale":[4.199999809265137,4.199999809265137,0.019999999552965164],"collision_layer":3}],["add","\/1034\/1037\/1038\/1054",false,"1055","CollisionShape",{}],["add","\/1034",false,"1056","Area",{"groups":["grabbable"],"scale":[0.0,0.0,0.019999999552965164],"collision_layer":3}],["add","\/1034\/1056",false,"1057","CollisionShape",{}]]
	apply_updates(j)

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

func apply_prop(instance, key, value):
	if key == 'groups':
		for group in value:
			instance.add_to_group(group)
		return
	
	if not key in instance:
		for s in instance.get_signal_list():
			if s['name'] == key:
				instance.connect(key, self, 'note_signal' + str(len(s['args'])), [value])
				return
		print("No property named " + key + " on " + str(instance))
		return
	
	instance.set(key, value)

# no variadic arguments, so have one signature per needed count of arguments...
func note_signal0(instance, block_id):
	pending_signal_handlers.append([instance, block_id])
func note_signal1(arg1, instance, block_id):
	pending_signal_handlers.append([instance, block_id, arg1])
func note_signal2(arg1, arg2, instance, block_id):
	pending_signal_handlers.append([instance, block_id, arg1, arg2])
