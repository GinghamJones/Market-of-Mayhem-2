extends Node

var names : Array[String] = []


func _ready():
	populate_names()


func get_new_name() -> String:
	randomize()
	var available_num_names : int = names.size()
	var index : int = randi() % available_num_names
	var name : String = names[index]
	names.erase(name)
	return name


func populate_names():
	names = ["Steve", "Larry", "Jim", "Jerry", "Bill", "Lucy", "Leslie", "Jeremy", "Stew", "Florence", "Bailey", "Rachel", "Evin", "Blake", "Roger",
			"Hannah", "Joe", "Mary", "Darlene", "Susan", "Carry", "Barry", "Gallihad", "Farris", "Eddy", "Junior", "Denise", "Dennis", "Pam", "Alice"]
