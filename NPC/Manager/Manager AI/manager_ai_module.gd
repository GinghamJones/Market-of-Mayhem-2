extends AIModule

@onready var wait_timer : Timer = $TargetWaitTimer

func run(controller : AIController):
	# Give players some time to recover by wandering
	if wait_timer.time_left > 0:
		wander(controller)
		return
		
	
	var detection_area : Area3D = controller.detection_area
	var check : bool = false
	var my_speed : float = controller.get_actor_speed()
	var current_target : Character = controller.target
	
	# If we have a target:
	if current_target:
		if current_target.is_dead:
			controller.set_target(null)
			return
		if controller.is_target_in_grab_distance():
			controller.grab_target()
			wait_timer.start()
			controller.set_target(null)
			return
	
	# If we don't have a target: NEED TO ADD FLEE METHOD
	else:
		check = detection_area.is_anyone_in_sight()
		# Wander if noone in sight
		if not check:
			wander(controller)
			return
		else:
			controller.set_target(detection_area.get_closest_opponent())
	
	# Default action
	controller.move_to_target()

func wander(controller : AIController):
	var nav_agent : NavigationAgent3D = controller.nav_agent
	if nav_agent.is_navigation_finished():
		while(true):
			var radius : float = 50.0
			var random_position = Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))
			controller.set_nav_target(random_position)
			if nav_agent.is_target_reachable():
				break
	
	controller.move_to_target()


func check_speed_difference(my_speed : float, targetter_speed : float) -> bool:
	var max_tolerance : float = 1.0
	var speed_difference : float = targetter_speed - my_speed
	
	if speed_difference > max_tolerance:
		return false
	
	return true
