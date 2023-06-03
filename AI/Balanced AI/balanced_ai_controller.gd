class_name BalancedAIController
extends AIController

var move_forward : bool = true

var strafe_dir : int = 0   # 0 = right, 1 = left
var distance_to_target : float = 0.0

var too_many_dudes : bool = false


#func initiate(new_actor):
#	super(new_actor)
#	var new_module = balanced_module.instantiate()
#	add_child(new_module)
#	ai_module_children = new_module.get_children()
#	cur_ai = new_module


func run(delta : float) -> void:
	if did_i_fire:
		request_action.emit("StopFire")
		did_i_fire = false
	global_position = controller_positioner.global_position
	set_direction(Vector3.ZERO)
#	if frames_till_run > 0:
#		frames_till_run -= 1
#	else:
#		detection_area.monitoring = true
#		frames_till_run = randi_range(1, 2)
	handle_target_selection()
#		detection_area.monitoring = false
	
	handle_movement()
	
	handle_attacking()
	
	global_position = controller_positioner.global_position
	direction_computed.emit(delta, direction)


func handle_target_selection() -> void:
	var num_in_sight : int = detection_area.get_num_in_sight()
	
	# Check for too many opponents in area
	if num_in_sight > 4:
		# Run away if so
		too_many_dudes = true
		set_nav_target(actor.global_position)
		set_flee_target(check_wander_target())
		return
		
	elif num_in_sight > 0:
		# If we have a target already, make sure it's still valid
		if target:
			check_current_target()
		else:
			target = detection_area.get_lowest_health_opponent()
	else: #dudes_in_sight == 0:
		# No one in sight, no need to select targets
		if is_fleeing:
			is_fleeing = false
		if target:
			set_target(null)
	
	# Check if being targetted and handle accordingly
	var targetter : Character = detection_area.am_i_targetted()
	if targetter:
		if is_health_too_low(targetter):
			set_flee_target(get_new_runaway_target())
			is_fleeing = true
		else:
			set_target(targetter)
	
	# Manager no iz good..
	var manager : Manager = detection_area.get_manager_in_sight()
	if manager:
		set_flee_target(-manager.global_position)
		is_fleeing = true


func handle_movement() -> void:
	if target == null:
		check_wander_target()
		move_to_target()
		return 
	
	if not back_up_timer.is_stopped():
		back_up()
		return
	
	if get_is_dodging():
		return
	
	if is_fleeing:
		move_to_target()
		return
	
	if is_dodge_available():
		if detection_area.is_projectile_comin_for_me():
			dodge(choose_dodge_direction())
			return
	
	check_movement_change()

	if move_forward:
		move_to_target()
	else:
		handle_strafe()


func handle_attacking() -> void:
	if not punch_anim_timer.is_stopped() or not punch_think_timer.is_stopped() or not fire_think_timer.is_stopped() or not target:
		return
	
	if check_punch_conditions():
		punch_think_timer.wait_time = randf_range(0.1, 0.2)
		punch_think_timer.start()
	
	if fire_think_timer.is_stopped():
		if check_fire_conditions():
			fire_think_timer.wait_time = randf_range(0.1, 0.2)
			fire_think_timer.start()


######################## Target Functions ##############################################
func get_new_runaway_target() -> Vector3:
	var opponents_in_sight : Array = detection_area.get_opponents_in_sight()
	var average_position : Vector3 = Vector3.ZERO
	for dude in opponents_in_sight:
		average_position += dude.global_position
	
	average_position /= opponents_in_sight.size()
	
#	print("got runaway target")
	return average_position


func check_current_target() -> void:
	if not target:
		print("no target?")
		return
	# Check if dead
	if target.is_dead:
		target = null
		return
	# Check if fleeing
	if target.controller.is_fleeing:
		if target.get_speed() < get_actor_speed():
			return
		else:
			target = detection_area.get_lowest_health_opponent()
			return
	# Check if health too high
	if is_health_too_low(target):
		set_flee_target(get_new_runaway_target())
		is_fleeing = true


func is_health_too_low(new_target : Character) -> bool:
	if new_target.get_health() - get_actor_health() > 50:
		return true
	
	return false


########################## Movement Functions #############################
func choose_dodge_direction() -> Vector3:
	var rand_int : int = randi() % 2
	if rand_int == 0:
		return Vector3.RIGHT
	else:
		return Vector3.LEFT


func check_wander_target():
	if nav_agent.is_navigation_finished():
		while(true):
			var radius : float = 50.0
			var random_position = Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))
			set_nav_target(random_position)
			if nav_agent.is_target_reachable():
				break


func check_movement_change() -> void:
	if change_movement_timer.is_stopped():
		move_forward = !move_forward
		if move_forward:
			change_movement_timer.wait_time = randf_range(0.1, 0.6)
		else:
			change_movement_timer.wait_time = randf_range(0.05, 0.2)
		change_movement_timer.start()


func handle_strafe() -> void:
	if strafe_dir_timer.is_stopped():
		strafe_dir = randi() % 2
		strafe_dir_timer.start()
#		print("strafing target")
	if strafe_dir == 0:
		strafe_right()
	else:
		strafe_left()


########################## Attack Functions ################################

func check_punch_conditions() -> bool:
	if is_punch_available():
		if is_target_in_punch_range():
			return true
	
	return false


func check_fire_conditions() -> bool:
	if is_projectile_available():
		if is_target_aimed_at():
			return true
	
	return false
