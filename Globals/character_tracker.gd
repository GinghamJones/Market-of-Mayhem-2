extends Node

var current_characters : Dictionary = {
	"Bakery" : [],
	"Floral" : [],
	"Meat" : [],
	"Cashier" : [],
	"Kitchen" : [],
	"Produce" : [],
	"Freight" : [],
}


func add_character(team : String, character : Character):
	current_characters[team].push_back(character)


func get_num_in_team(team : String) -> int:
	return current_characters[team].size()


func get_personal_score(name : String, team : String) -> int:
	var chars_in_team : Array[Character] = current_characters[team]
	for char in chars_in_team:
		if char.character_stats.name == name:
			return char.character_stats.score
	
	printerr("Invalid get character score")
	return -1


func get_team_score(team : String) -> int:
	var team_score : int = 0
	for char in current_characters[team]:
		team_score += char.character_stats.score
	
	return team_score
