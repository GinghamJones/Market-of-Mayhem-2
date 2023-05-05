class_name GameMode
extends Node

@onready var start_timer : Timer = $Timers/StartRoundTimer
@onready var intermission_timer : Timer = $Timers/IntermissionTimer
@onready var world : PackedScene = preload("res://World/world.tscn")
@onready var countdown_text : Label = $GUI/CountdownText

var current_characters : Dictionary = {
	"Bakery" : [],
	"Floral" : [],
	"Meat" : [],
	"Cashier" : [],
	"Kitchen" : [],
	"Produce" : [],
	"Freight" : [],
}

var player_character_type : String = "Meat"
var current_world : Node3D = null

var max_rounds : int = 3
var current_round : int = 0


func _ready():
	countdown_text.hide()
	spawn_world()
	call_deferred("add_character", player_character_type, true)


func _process(delta):
	if not start_timer.is_stopped():
		var time_left : int = int(start_timer.time_left)
		countdown_text.text = str(time_left)

func spawn_world():
	current_world = world.instantiate()
	add_child(current_world)
	SpawnManager.populate_spawn_points()
	

func add_character(character_type : String, player_controlled : bool) -> void:
	var spawn_number : int = current_characters[character_type].size()

	if spawn_number > 2:
		printerr("Too many " + character_type + "s")
		return
	else:
		var new_character : Character = SpawnManager.get_new_character(character_type, player_controlled, spawn_number)
		current_characters[character_type].push_back(new_character)
		add_child(new_character)
		new_character.initiate()
		new_character.score_changed.connect(Callable($GUI, "score_changed"))


func get_score(team : String, char_name : String) -> int:
	for c in current_characters[team]:
		if char_name == c.character_stats.my_name:
			return c.score
	
	printerr("Couldn't find character for scoring")
	return -1




