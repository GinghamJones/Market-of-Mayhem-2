extends Control

@onready var player_movement = preload("res://Characters/Resources/player_movement.tscn").instantiate()
@onready var ai_controller = preload("res://Characters/Resources/AI/ai_controller.tscn")
@onready var world : PackedScene = preload("res://World/world.tscn")
@onready var dev_mode : PackedScene = preload("res://Menu/GameSelect/GameModes/dev_mode.tscn")
@onready var characters : Dictionary = {
	0 : preload("res://Characters/Bakery/baker.tscn"),
	1 : preload("res://Characters/Cashier/cashier.tscn"),
	2 : preload("res://Characters/Floral/florist.tscn"),
	3 : preload("res://Characters/Kitchen/kitchen_dude.tscn"),
	4 : preload("res://Characters/Meat/meat_seafood_dude.tscn"),
	5 : preload("res://Characters/Freight/freight.tscn"),
	6 : preload("res://Characters/Produce/produce_clerk.tscn")
}

var selected_char : String = ""


func _on_character_select_item_selected(index):
	match index:
		0:
			selected_char = "Bakery"
		1:
			selected_char = "Cashier"
		2:
			selected_char = "Floral"
		3:
			selected_char = "Kitchen"
		4:
			selected_char = "Meat"
		5:
			selected_char = "Freight"
		6:
			selected_char = "Produce"


func _on_devmode_pressed():
#	var gm : GameMode = dev_mode.instantiate()
#	gm.player_character_type = selected_char
#	get_tree().root.add_child(gm)
	SceneLoader.load_game_mode("DevMode", selected_char)
	
	queue_free()


#func spawn_ai(new_world):
#	if spawn_one_enemy:
#		var new_character = characters[2].instantiate()
#		new_character.player_controlled = false
#		var new_controller = ai_controller.instantiate()
#		new_character.add_child(new_controller)
#		new_world.add_child(new_character)
#		new_character.call_deferred("initiate")
#		new_character.spawn_point = get_tree().get_first_node_in_group("CashierSpawn").global_position
#
#	else:
#		for i in characters.size():
#			for j in 3:
#				var new_character = characters[i].instantiate()
#				new_character.player_controlled = false
#				var new_controller = ai_controller.instantiate()
#				new_character.add_child(new_controller)
#				new_world.add_child(new_character)
#				new_character.call_deferred("initiate")
#
#				var spawn_points
#				if new_character is Baker:
#					spawn_points = get_tree().get_nodes_in_group("BakerSpawn")
#					new_character.spawn_point = spawn_points[j].global_position
#				elif new_character is Cashier:
#					spawn_points = get_tree().get_nodes_in_group("CashierSpawn")
#					new_character.spawn_point = spawn_points[j].global_position
#				elif new_character is MeatDude:
#					spawn_points = get_tree().get_nodes_in_group("MeatSpawn")
#					new_character.spawn_point = spawn_points[j].global_position
#				elif new_character is Florist:
#					spawn_points = get_tree().get_nodes_in_group("FloristSpawn")
#					new_character.spawn_point = spawn_points[j].global_position
#				elif new_character is Produce:
#					spawn_points = get_tree().get_nodes_in_group("ProduceSpawn")
#					new_character.spawn_point = spawn_points[j].global_position
#				elif new_character is Freight:
#					spawn_points = get_tree().get_nodes_in_group("FreightSpawn")
#					new_character.spawn_point = spawn_points[j].global_position
#				elif new_character is KitchenDude:
#					spawn_points = get_tree().get_nodes_in_group("KitchenSpawn")
#					new_character.spawn_point = spawn_points[j].global_position

func _on_quit_button_pressed():
	get_tree().quit()

