extends Node


@onready var strafe_dir_timer : Timer = $StrafeDirTimer

var strafe_dir : int = 0   # 0 = right, 1 = left
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
	############################################################################
	
	
	############################################################################
	############################# Flee Mode ####################################
	
	if controller.flee_target:
		controller.flee_from_target()
#		print("fleeing target")
		return 
	
	############################################################################
	############################################################################
	
	
	############################################################################
	########################### Attack Mode ####################################
	var target_pos : Vector3 = controller.get_target_pos()
	var actor_pos : Vector3 = controller.get_actor_pos()
	
	distance_to_target = get_distance_to_target(actor_pos, target_pos)
	
	check = should_move_to_enemy(actor_pos, target_pos)
	if check:
		controller.move_to_target()
#		print("moving to target")
		return 
	else:
		if strafe_dir_timer.is_stopped():
			strafe_dir = get_strafe_dir()
			strafe_dir_timer.start()
#		print("strafing target")
		if strafe_dir == 0:
			controller.strafe_right()
		else:
			controller.strafe_left()
		return 

	
	############################################################################
	############################################################################



func get_distance_to_target(actor_pos : Vector3, target_pos : Vector3) -> float:
	return actor_pos.distance_to(target_pos)


func should_move_to_enemy(my_pos : Vector3, target_pos : Vector3) -> bool:
	if distance_to_target > 1.5:
		return true
	else:
		return false

func get_strafe_dir() -> int:
	var rand_int : int = randi() % 2
	return rand_int
	
