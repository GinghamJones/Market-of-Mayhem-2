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
#var spawned_characters : Dictionary = {
#	"baker" : [],
#	"cashier" : [],
#	"florist" : [],
#	"cook" : [],
#	"butcher" : [],
#	"freight" : [],
#	"produce" : []
#}



func get_new_character(character_type : String, player_controlled : bool, spawn_point_number : int) -> Character:
	var new_character : Character = characters_available[character_type].instantiate()
	
	if player_controlled:
		var new_controller = player_movement.instantiate()
		new_character.add_child(new_controller)
	else:
		# Add code for choosing random personality. Maybe weighted based on class chosen
		var new_controller = ai_controller.instantiate()
		new_character.add_child(new_controller)
	
#	var spawn_point_number : int = spawned_characters[team].size()
#	if spawn_point_number > 2:
#		# >2 will return invalid get index on spawn_points array. Abort mission.
#		new_character.queue_free()
#		printerr("Too many characters on this team")
#		return null
		
	new_character.spawn_point = spawn_points[character_type][spawn_point_number].global_position
#	spawned_characters[team].push_back(new_character)
#	new_character.call_deferred("initiate")
#	new_character.initiate()
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
