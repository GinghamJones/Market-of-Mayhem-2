extends Control

@onready var player_movement = preload("res://Characters/Resources/player_movement.tscn").instantiate()
@onready var ai_movement = preload("res://Characters/Resources/ai_movement.tscn")
@onready var world : PackedScene = preload("res://World/world.tscn")
@onready var characters : Dictionary = {
	0 : preload("res://Characters/Bakery/baker.tscn"),
	1 : preload("res://Characters/Cashier/cashier.tscn"),
	2 : preload("res://Characters/Floral/florist.tscn"),
	3 : preload("res://Characters/Kitchen/kitchen_dude.tscn"),
	4 : preload("res://Characters/Meat/meat_seafood_dude.tscn"),
	5 : preload("res://Characters/Freight/freight.tscn"),
	6 : preload("res://Characters/Produce/produce_clerk.tscn")
}

var selected_char : int = -1


func _on_character_select_item_selected(index):
	selected_char = index


func _on_start_pressed():
	
	var new_world = world.instantiate()
	get_tree().root.add_child(new_world)
	
	if not spawn_player(new_world):
		return
	spawn_ai(new_world)
	
	queue_free()


func spawn_player(new_world) -> bool:
	if selected_char < 0 or selected_char > characters.size():
		return false
	var character = characters[selected_char].instantiate()
	character.player_controlled = true
	character.add_child(player_movement)
	character.call_deferred("initiate")
	new_world.add_child(character)
	character.global_position = get_tree().get_first_node_in_group("PlayerSpawn").global_position
	return true


func spawn_ai(new_world):
	var spawn_points = get_tree().get_nodes_in_group("Spawn")
	
	for i in characters.size():
		for j in 3:
			var new_character = characters[i].instantiate()
			new_character.player_controlled = false
			new_world.add_child(new_character)
			var am = ai_movement.instantiate()
			new_character.add_child(am)
			new_character.call_deferred("initiate")
			if new_character is Baker:
				new_character.global_position = spawn_points[j].global_position
			elif new_character is Cashier:
				new_character.global_position = spawn_points[j + 3].global_position


func _on_quit_button_pressed():
	get_tree().quit()
