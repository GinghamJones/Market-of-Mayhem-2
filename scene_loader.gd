extends Node

@onready var game_select : PackedScene = preload("res://Menu/GameSelect/GameSelect.tscn")
@onready var dev_mode : PackedScene = preload("res://Menu/GameSelect/GameModes/dev_mode.tscn")
@onready var timed_mode : PackedScene = preload("res://Menu/GameSelect/GameModes/timed_mode.tscn")
@onready var world = preload("res://World/world.tscn").instantiate()
@onready var settings = preload("res://Menu/Settings/settings.tscn").instantiate()
#@export var game_select : PackedScene
#@export var dev_mode : PackedScene
#@export var timed_mode : PackedScene
var current_scene : Node = null


func _ready():
	call_deferred("load_character_select")
	add_child(settings)
	add_child(world)
	settings.initiate()
	settings.hide()
	settings.connect("main_menu_request", Callable(self, "load_character_select"))
	world.hide()
	for i in 10:
		var rand = randi() % 2
		print(rand)

func load_character_select():
	destroy_cur_scene()

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var char_select = game_select.instantiate()
	char_select.connect("change_scene", Callable(self, "load_game_mode"))
	add_child(char_select)
	current_scene = char_select


func load_game_mode(game_mode : String, player_type : String, player_name : String):
	destroy_cur_scene()
	var gm : GameMode = null
	
	if game_mode == "DevMode":
		gm = dev_mode.instantiate()
	elif game_mode == "TimedMode":
		gm = timed_mode.instantiate()
	
	gm.connect("load_character_select", Callable(self, "load_character_select"))
	gm.connect("need_settings", Callable(self, "show_settings"))
	gm.connect("fuck_the_settings", Callable(self, "hide_settings"))
	gm.player_character_type = player_type
	gm.player_name = player_name
	
	add_child(gm)
	world.reparent(gm)
	world.show()
	current_scene = gm


func show_settings():
	settings.show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func hide_settings():
	settings.hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func destroy_cur_scene():
	if current_scene:
		world.reparent(self)
		current_scene.queue_free()
		current_scene = null
		get_tree().paused = false
