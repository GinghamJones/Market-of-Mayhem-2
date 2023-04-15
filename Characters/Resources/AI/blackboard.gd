class_name Blackboard
extends Resource

var data : Dictionary


func set_data(name : String, value):
	data[name] = value

func get_data(name : String):
	return data[name]
