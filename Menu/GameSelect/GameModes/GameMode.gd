class_name GameMode
extends Node

@onready var start_timer : Timer = $Timers/StartRoundTimer
@onready var intermission_timer : Timer = $Timers/IntermissionTimer
@onready var countdown_text : Label = $GUI/CountdownText
@onready var intermission_text : Label = $GUI/IntermissionText
@onready var scoreboard = $GUI/ScoreBoard

var current_characters : Dictionary = {
	"Bakery" : [],
	"Floral" : [],
	"Meat" : [],
	"Cashier" : [],
	"Kitchen" : [],
	"Produce" : [],
	"Freight" : [],
}
var manager : Manager = null
var world = null

var player_character_type : String = ""
var player_name : String = ""
var current_world : Node3D = null

var max_rounds : int = 3
var current_round : int = 0

var is_paused : bool = false

signal load_character_select
signal need_settings
signal fuck_the_settings


func _ready():
	countdown_text.hide()
#	world.play_song()


func _input(event):
	if event.is_action_pressed("ShowScoreboard"):
		$GUI/ScoreBoard.show()
	if event.is_action_released("ShowScoreboard"):
		$GUI/ScoreBoard.hide()
	
	if event.is_action_pressed("Pause"):
		if not is_paused:
			is_paused = true
			need_settings.emit()
		else:
			is_paused = false
			fuck_the_settings.emit()


func _process(_delta):
	if not start_timer.is_stopped():
		var time_left : int = int(start_timer.time_left)
		countdown_text.text = str(time_left)
	
	if not intermission_timer.is_stopped():
		var time_left : float = intermission_timer.time_left
		intermission_text.text = "%2.2f" % time_left


func add_character(character_type : String, player_controlled : bool, character_name : String = NameGenerator.get_new_name()) -> void:
	var spawn_number : int = current_characters[character_type].size()

	if spawn_number > 2:
		printerr("Too many " + character_type + "s")
		return
	else:
		var new_character : Character = SpawnManager.get_new_character(character_type, player_controlled, spawn_number)
		new_character.name = character_name
		new_character.character_stats.my_name = character_name
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





