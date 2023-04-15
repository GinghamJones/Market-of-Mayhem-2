extends Action


func run(actor, controller) -> bool:
	var current_position : Vector3 = actor.global_position
	var next_position : Vector3 = controller.nav_agent.get_next_path_position()
	var target_direction = (next_position - current_position).normalized() 
	controller.direction = target_direction
	controller.y_rotation = atan2(-target_direction.x, -target_direction.z)
	return true
