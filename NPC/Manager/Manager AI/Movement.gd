extends Node


var distance_to_target : float = 0.0


func run(controller : AIController):
	
	var check : bool = false
	
	############################################################################
	########################### Wander Mode ####################################
	
	if controller.target == null:
		var nav_agent : NavigationAgent3D = controller.nav_agent
		if nav_agent.is_navigation_finished():
			while(true):
				var radius : float = 50.0
				var random_position = Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))
				controller.set_nav_target(random_position)
				if nav_agent.is_target_reachable():
					break
		
		controller.move_to_target()
#		print("wandering")
		return 
	
	
	############################################################################
	############################# Flee Mode ####################################
	
	if controller.flee_target:
		controller.flee_from_target()
#		print("fleeing target")
		return 
	
	
	############################################################################
	########################### Attack Mode ####################################
	var target_pos : Vector3 = controller.get_target_pos()
	var actor_pos : Vector3 = controller.get_actor_pos()
	
	distance_to_target = get_distance_to_target(actor_pos, target_pos)
	
	check = should_move_to_enemy()
	if check:
		controller.move_to_target()
	else:
		if controller.is_target_in_grab_distance():
			controller.grab_target()
	
	############################################################################
	############################################################################



func get_distance_to_target(actor_pos : Vector3, target_pos : Vector3) -> float:
	return actor_pos.distance_to(target_pos)


func should_move_to_enemy() -> bool:
	if distance_to_target > 1.0:
		return true
	else:
		return false

