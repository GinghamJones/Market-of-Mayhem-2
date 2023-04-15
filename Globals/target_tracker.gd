extends Node

var targets : Dictionary

func set_target(attacker : Character, target : Character):
	targets[attacker] = target


func get_targetter(requester : Character):
	return targets.find_key(requester)


func get_target_count(target : Character) -> int:
	var values = targets.values()
	var num_targetting : int = 0
	for value in values:
		if value == target:
			num_targetting += 1
	
	return num_targetting


func remove_target(attacker : Character):
	targets.erase(attacker)
