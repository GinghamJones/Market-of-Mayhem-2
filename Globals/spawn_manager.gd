extends Node

@onready var characters_available : Dictionary = {
	"Bakery" : preload("res://Characters/Bakery/baker.tscn"),
	"Cashier" : preload("res://Characters/Cashier/cashier.tscn"),
	"Floral" : preload("res://Characters/Floral/florist.tscn"),
	"Kitchen" : preload("res://Characters/Kitchen/kitchen_dude.tscn"),
	"Meat" : preload("res://Characters/Meat/meat_seafood_dude.tscn"),
	"Freight" : preload("res://Characters/Freight/freight.tscn"),
	"Produce" : preload("res://Characters/Produce/produce_clerk.tscn")
}
@onready var player_movement = preload("res://Characters/Resources/player_movement.tscn")
@onready var ai_controller = preload("res://Characters/Resources/AI/ai_controller.tscn")

var spawn_points : Dictionary = {}




func get_new_character(character_type : String, player_controlled : bool, spawn_point_number : int) -> Character:
	var new_character : Character = characters_available[character_type].instantiate()
	
	if player_controlled:
		var new_controller = player_movement.instantiate()
		new_character.player_controlled = true
		new_character.add_child(new_controller)
	else:
		# Add code for choosing random personality. Maybe weighted based on class chosen
		var new_controller = ai_controller.instantiate()
		new_character.add_child(new_controller)
	
		
	new_character.spawn_point = spawn_points[character_type][spawn_point_number].global_position

	return new_character


func populate_spawn_points():
	spawn_points = {
		"Bakery" : get_tree().get_nodes_in_group("BakerSpawn"),
		"Cashier" : get_tree().get_nodes_in_group("CashierSpawn"),
		"Floral" : get_tree().get_nodes_in_group("FloristSpawn"),
		"Kitchen" : get_tree().get_nodes_in_group("KitchenSpawn"),
		"Meat" : get_tree().get_nodes_in_group("MeatSpawn"),
		"Freight" : get_tree().get_nodes_in_group("FreightSpawn"),
		"Produce" : get_tree().get_nodes_in_group("ProduceSpawn")
	}
