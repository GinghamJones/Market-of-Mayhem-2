extends Node

@onready var timer : Timer = $TargetWaitTimer

func run(controller : AIController):
	var detection_area : Area3D = controller.detection_area
	var check : bool = false
	var my_speed : float = controller.get_actor_speed()
	var current_target : Character = controller.target
	
	######################### Important checks ##########################################
	# Check if anyone in sight
	check = detection_area.is_anyone_in_sight()
	if not check:
		return 
	
	#####################################################################################
	
	# Check if they dead or if no target chosen yet
	
	if current_target != null:
		if current_target.is_dead:
			controller.set_target(null)
			return
	else:
		controller.set_target(detection_area.get_closest_opponent())
		return

	if current_target.controller.get_fleeing():
		check = check_speed_difference(my_speed, current_target.get_speed())
		if not check:
			controller.set_target(detection_area.get_closest_opponent())
	return 


#####################################################################################
#####################################################################################
#####################################################################################


func check_health_difference(my_health : int, target_health : int) -> bool:
	var max_tolerance : int = 50
	var health_difference : int = target_health - my_health
	
	if health_difference > max_tolerance:
		return false
	
	return true


func check_speed_difference(my_speed : float, targetter_speed : float) -> bool:
	var max_tolerance : float = 1.0
	var speed_difference : float = targetter_speed - my_speed
	
	if speed_difference > max_tolerance:
		return false
	
	return true
