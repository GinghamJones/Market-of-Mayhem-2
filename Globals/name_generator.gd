extends Node

var names : Array[String] = []


func _ready():
	populate_names()


func get_new_name() -> String:
	randomize()
	var available_num_names : int = names.size()
	var index : int = randi() % available_num_names
	var my_name : String = names[index]
	names.erase(my_name)
	return my_name


func populate_names():
	names = ["Steve", "Larry", "Jim", "Jerry", "Bill", "Lucy", "Leslie", "Jeremy", "Stew", "Florence", "Bailey", "Rachel", "Evin", "Blake", "Roger",
			"Hannah", "Joe", "Mary", "Darlene", "Susan", "Carry", "Barry", "Gallihad", "Farris", "Eddy", "Junior", "Denise", "Dennis", "Pam", "Alice"]
