extends Node

@onready var character_select : PackedScene = preload("res://Menu/GameSelect/GameSelect.tscn")
@onready var dev_mode : PackedScene = preload("res://Menu/GameSelect/GameModes/dev_mode.tscn")
var current_scene : Node = null


func _ready():
	for node in get_tree().root.get_children():
		if node is Control:
			current_scene = node
			break


func load_character_select():
	destroy_cur_scene()
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var shit = character_select.instantiate()
	get_tree().root.add_child(shit)


func load_game_mode(game_mode : String, player_type : String):
	destroy_cur_scene()
	
	if game_mode == "DevMode":
		var gm : GameMode = dev_mode.instantiate()
		gm.player_character_type = player_type
		get_tree().root.add_child(gm)
		current_scene = gm


func destroy_cur_scene():
	if current_scene:
		current_scene.queue_free()
		current_scene = null
