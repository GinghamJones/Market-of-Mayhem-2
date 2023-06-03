#extends Node
#
#@onready var master = get_parent()
#@onready var controller : AIController = master.controller
#var frames_till_run : int = 3
#
######################################################################################
############################### Main Function ########################################
######################################################################################
#
#func run():
#	frames_till_run -= 1
#	if frames_till_run == 0:
#		frames_till_run = 3
#	else:
#		return
#
#	var detection_area : Area3D = controller.detection_area
#	var current_target : Character = controller.target
##	var flee_target : Character = controller.flee_target
#
#	var check : bool = false
#	var my_health : int = controller.get_actor_health()
#	var my_speed : float = controller.get_actor_speed()
#
#	######################### Important checks ##########################################
#	# Check if anyone in sight
#	var dudes_in_sight : int = detection_area.get_dudes_in_sight()
##	check = detection_area.get_dudes_in_sight()
#	if dudes_in_sight == 0:
#		# No one in sight, no need to select targets
#		if flee_target:
#			controller.set_flee_target(null)
#		if current_target:
#			controller.set_target(null)
#		return 
#	elif dudes_in_sight > 3:
#		master.too_many_dudes = true
#		return
#
#	# Check for managers
#	var manager : Manager = detection_area.get_manager_in_sight()
#	if manager != null:
#		# Oh shit, manager in sight. Fuck everything else, better run...
#		controller.set_flee_target(manager)
#		return 
#
#	# Check if being targetted
#	var targetter : Character = detection_area.am_i_targetted()
#	if targetter:
#		check = should_i_fight(targetter, my_health, my_speed)
#
#		if not check:
#			controller.set_flee_target(targetter)
#		else:
#			controller.set_target(targetter)
#			current_target = targetter
##			return 
#
#	#####################################################################################
#
#	# Check if they dead or if no target chosen yet
#	if current_target != null:
#		if current_target.is_dead:
#			controller.set_target(null)
#			return
#	else:
#		controller.set_target(detection_area.get_closest_opponent())
#		return
#
#	# Check target health
#	check = check_health_difference(my_health, current_target.get_health())
#	if not check:
#		controller.set_flee_target(current_target)
#		return 
#
#
#	if current_target.controller.get_fleeing():
#		check = check_speed_difference(my_speed, current_target.get_speed())
#		if not check:
#			controller.set_target(detection_area.get_closest_opponent())
#	return 
#
#
######################################################################################
######################################################################################
######################################################################################
#
#
#func should_i_fight(targetter : Character, my_health : int, my_speed : float) -> bool:
#
#	var health_ok : bool = check_health_difference(my_health, targetter.get_health())
#	var speed_ok : bool = check_speed_difference(my_speed, targetter.get_speed())
#
#	if speed_ok and not health_ok:
#		return false
#	else:
#		return true
#
#
#func check_health_difference(my_health : int, target_health : int) -> bool:
#	var max_tolerance : int = 50
#	var health_difference : int = target_health - my_health
#
#	if health_difference > max_tolerance:
#		return false
#
#	return true
#
#
#func check_speed_difference(my_speed : float, targetter_speed : float) -> bool:
#	var max_tolerance : float = 1.0
#	var speed_difference : float = targetter_speed - my_speed
#
#	if speed_difference > max_tolerance:
#		return false
#
#	return true
