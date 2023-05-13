extends Condition

func run(actor : Character, controller : AIController) -> int:
	var enemy_pos : Vector3 = controller.target.global_position
	var my_pos : Vector3 = actor.global_position
	var distance_to_enemy : float = my_pos.distance_to(enemy_pos)
	
	if distance_to_enemy < 0.1:
		print("am i strafing enemy")
		return SUCCESS
	else:
		return FAILURE
