extends Node

@onready var world : PackedScene = preload("res://World/world.tscn")
@onready var character_select : PackedScene = preload("res://Menu/GameSelect/GameSelect.tscn")


func load_character_select():
	get_tree().get_first_node_in_group("World").queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_packed(character_select)
	

