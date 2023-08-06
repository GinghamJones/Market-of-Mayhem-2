extends Node

@onready var wait_timer : Timer = $TargetWaitTimer
@onready var think_timer : Timer = $RandomThinkTimer

func run(controller : ManagerController):
	# Give players some time to recover by wandering
	if wait_timer.time_left > 0:
		wander(controller)
		return
		
	
	var detection_area : Area3D = controller.detection_field
#	var check : bool = false
#	var my_speed : float = controller.get_actor_speed()
	var current_target : Character = controller.target
	
	# If we have a target:
	if current_target:
		if current_target.is_dead:
			controller.target = null
			return
		if controller.is_target_in_grab_distance():
			if think_timer.is_stopped():
				var rand_float : float = randf_range(0.1, 0.3)
				think_timer.wait_time = rand_float
				think_timer.start()
				controller.current_timer = think_timer
#			controller.target = null
			return
	
	# If we don't have a target: NEED TO ADD CHARACTER FLEEING METHOD
	else:
		var num_sighted : int = detection_area.get_dudes_in_sight()
		# Wander if noone in sight
		if num_sighted == 0:
			wander(controller)
			return
		else:
			controller.target = (detection_area.get_closest_opponent())
	
	# Default action
	controller.move_to_target()


func wander(controller : ManagerController):
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


func activate_attack() -> void:
	get_parent().grab_target()
