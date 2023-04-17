extends Condition

func run(actor : Character, controller : Controller) -> bool:
	var enemy_pos : Vector3 = controller.target.global_position
	var my_pos : Vector3 = actor.global_position
	var distance_to_enemy : float = my_pos.distance_to(enemy_pos)
	
	if distance_to_enemy < 1.5:
		return false
	else:
		return true
