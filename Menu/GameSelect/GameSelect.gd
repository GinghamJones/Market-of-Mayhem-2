extends Control

@onready var player_movement = preload("res://Characters/Resources/player_movement.tscn").instantiate()
@onready var world : PackedScene = preload("res://World/world.tscn")
@onready var characters : Dictionary = {
	0 : preload("res://Characters/Bakery/baker.tscn"),
	1 : preload("res://Characters/Cashier/cashier.tscn")
}

var selected_char : int = -1


func _on_character_select_item_selected(index):
	selected_char = index


func _on_start_pressed():
	if selected_char < 0 or selected_char > characters.size():
		return
	var new_world = world.instantiate()
	get_tree().root.add_child(new_world)
	
	# Spawn player character
	var character = characters[selected_char].instantiate()
	character.add_child(player_movement)
	character.controller = player_movement
	new_world.add_child(character)
	character.set_player_controlled(true)
	character.global_position = new_world.find_child("SpawnPoint").global_position
	
	# Spawn opponent characters
	var spawn_points = get_tree().get_nodes_in_group("Spawn")
	
	for i in characters.size():
		for j in 3:
			print(j)
			var new_character = characters[i].instantiate()
			print(characters[i])
			new_character.set_player_controlled(false)
			new_world.add_child(new_character)
			if new_character is Baker:
				print("baker")
				new_character.global_position = spawn_points[j].global_position
			elif new_character is Cashier:
				print("cashier")
				new_character.global_position = spawn_points[j + 3].global_position
	
	queue_free()
	
