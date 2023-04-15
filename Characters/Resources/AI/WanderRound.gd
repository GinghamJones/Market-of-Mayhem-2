extends Action


func run(actor, controller) -> bool:
	var nav_agent : NavigationAgent3D = controller.nav_agent
	if nav_agent.is_navigation_finished():
		while(true):
			var radius : float = 50.0
			var random_position = Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))
			nav_agent.set_target_position(random_position)
			if nav_agent.is_target_reachable():
				return true
	
	return false
	
	
