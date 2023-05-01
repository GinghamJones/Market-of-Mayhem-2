class_name GameMode
extends Node


@onready var world : PackedScene = preload("res://World/world.tscn")

var current_characters : Dictionary = {
	"Bakery" : [],
	"Floral" : [],
	"Meat" : [],
	"Cashier" : [],
	"Kitchen" : [],
	"Produce" : [],
	"Freight" : [],
}

var player_character_type : String = ""
var current_world : Node3D = null


func _ready():
	spawn_world()
	call_deferred("add_character", player_character_type, true)


func spawn_world():
	current_world = world.instantiate()
	add_child(current_world)
	SpawnManager.populate_spawn_points()
	

func add_character(character_type : String, player_controlled : bool) -> void:
	var spawn_number : int = current_characters[character_type].size()
#	var spawn_number : int = CharacterTracker.get_num_in_team(character_type)
	if spawn_number > 2:
		printerr("Too many " + character_type + "s")
		return
	else:
		var new_character : Character = SpawnManager.get_new_character(character_type, player_controlled, spawn_number)
		current_characters[character_type].push_back(new_character)
		add_child(new_character)
		new_character.initiate()
		new_character.score_changed.connect(Callable(self, "score_changed"))


func score_changed():
	pass
