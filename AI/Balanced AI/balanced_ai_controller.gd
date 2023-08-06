class_name BalancedAIController
extends AIController 

var target_action : String
var movement_action : String
var attack_action : String

func run(delta : float) -> void:
	if did_i_fire:
		request_action.emit("StopFire")
		did_i_fire = false
#	global_position = controller_positioner.global_position
	set_direction(Vector3.ZERO)

	handle_target_selection()
#		detection_area.monitoring = false
	handle_movement()
	handle_attacking()
	
	DebugDraw.set_text("Target action: " + str(self.name), target_action, 0, Color.WHITE_SMOKE)
	DebugDraw.set_text("Movement action: " + str(self.name), movement_action, 1, Color.WHITE_SMOKE)
	DebugDraw.set_text("Attack action: " + str(self.name), attack_action, 2, Color.WHITE_SMOKE)
	
	
#	detection_area.reset()
	global_position = controller_positioner.global_position
#	direction = direction.normalized()
#	direction_computed.emit(delta, direction)


func handle_target_selection() -> void:
#	if is_fleeing:
#		target_action = "fleeing"
#		return
	if not target_think_timer.is_stopped() or not forget_target.is_stopped():
		target_action = "thinking"
		return
	# Using this, we populate the opponents_in_sight array in detection_area
	var num_in_sight : int = detection_area.get_num_in_sight()
	
#	print(str(num_in_sight))
	# Check for too many opponents in area
	if num_in_sight > 4:
		# Run away if so
#		too_many_dudes = true
#		set_target(null, true)
#		is_fleeing = true
		target_action = "too many dudes"
#		set_nav_target(actor.global_position)
#		set_flee_target(check_wander_target())
		return
	elif num_in_sight > 0:
		# If we have a target already, make sure it's still valid
		if target:
			check_current_target()
			target_action = "checked current target"
		else:
			set_target(detection_area.get_lowest_health_opponent(), false)
			target_action = "got lowest health opponent"
		
		projectile_available = is_projectile_available()
			
#		var targetters : Array[CharacterBody3D] = detection_area.get_targetters()
#		if targetters.size() == 0:
#			pass
#		else:
#			parse_targetters(targetters)
#			return
	else: #dudes_in_sight == 0:
		# No one in sight, no need to select targets
		target_action = "no target"
		if target:
			target_action = "forgetting"
			if forget_target.is_stopped():
				set_target(null, false)
	
	
	
	# Check if being targetted and handle accordingly
#	var targetter : Character = detection_area.am_i_targetted()
#	if targetter:
#		if is_health_too_low(targetter):
#			set_flee_target(get_new_runaway_target())
#			is_fleeing = true
#		else:
#			set_target(targetter)
#
#	# Manager no iz good..
#	var manager : Manager = detection_area.get_manager_in_sight()
#	if manager:
#		set_flee_target(-manager.global_position)
#		is_fleeing = true


func handle_movement() -> void:
#	if is_fleeing:
#		flee()
#		movement_action = "fleeing"
#		return
	
	if target == null:
		check_wander_target()
		move_to_target()
		movement_action = "wandering"
		return 
	
	if not back_up_timer.is_stopped():
		back_up()
		movement_action = "backing up"
		return
	
	if get_is_dodging():
		movement_action = "dodging"
		return
	
	if is_dodge_available():
		if detection_area.is_projectile_comin_for_me():
			dodge(choose_dodge_direction())
			movement_action = "chose to dodge"
			return

	check_movement_change()

	if move_forward:
		move_to_target(projectile_available)
		movement_action = "moving forward"
	else:
		handle_strafe()
		movement_action = "strafing"


func handle_attacking() -> void:
	if not fire_think_timer.is_stopped():
		attack_action = "thinking about firing"
	if not punch_think_timer.is_stopped():
		attack_action = "thinking about punching"
	if not punch_anim_timer.is_stopped() or not target:
		attack_action = "null"
		return
	
	if punch_think_timer.is_stopped():
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
		set_target(null, false)
		return
	# Check if fleeing
	if target.controller.is_fleeing:
		if target.get_speed() < get_actor_speed():
			return
		else:
			set_target(detection_area.get_lowest_health_opponent(), false)
			return
	# Check if health too high
	if is_health_too_low(target):
#		var vector_away_from : Vector3 = (target.global_position - actor.global_position).normalized()
#		set_flee_target(vector_away_from)
		set_is_fleeing(true)


func parse_targetters(targetters : Array[CharacterBody3D]):
	for dude in targetters:
		if dude is Manager:
			set_target(null, true)
#			set_flee_target(dude.global_position)
			is_fleeing = true
			return
		else:
			if is_health_too_low(dude):
				set_target(null, true)
				is_fleeing = true
#				var vector_away_from : Vector3 = (dude.global_position - actor.global_position).normalized()
#				set_flee_target(vector_away_from)
			else:
				set_target(dude, false)





########################## Movement Functions #############################


########################## Attack Functions ################################

#func check_punch_conditions() -> bool:
#	if is_punch_available():
#		if is_target_in_punch_range():
#			return true
#
#	return false
#
#
#func check_fire_conditions() -> bool:
#	if is_projectile_available():
#		if is_target_aimed_at():
#			return true
#
#	return false
