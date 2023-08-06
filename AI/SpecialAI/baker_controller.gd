extends AIController

@onready var manager_flee_timer: Timer = $Node/ManagerFleeTimer
@onready var firing_rotation_timer: Timer = $Node/FiringRotationTimer

var target_slowed : bool = false
var manager_in_sight : Manager = null
var turning_left : bool = false

func run(delta : float) -> void:
	if did_i_fire:
		request_action.emit("StopFire")
		did_i_fire = false
	
	set_direction(Vector3.ZERO)
	
	handle_target_selection()
	
	handle_movement()
	
	handle_attacking()
	
	detection_area.reset()
	global_position = controller_positioner.global_position
#	direction = direction.normalized()
#	direction_computed.emit(delta, direction)

################################ Main Running Functions #######################################

func handle_target_selection() -> void:
#	if not forget_target.is_stopped():
#		return
	
	if manager_in_sight:
		if target:
			set_target(null, true)
			set_nav_target((manager_in_sight.global_position - actor.global_position).normalized() * 2)
		else:
			set_nav_target((manager_in_sight.global_position - actor.global_position).normalized() * 2)
		
		return
	
	var num_in_sight : int = detection_area.get_num_in_sight()
	
	if num_in_sight > 0:
		if target:
			check_current_target()
		else:
			set_target(detection_area.get_lowest_health_opponent(), false)
		
		var targetters : Array[CharacterBody3D] = detection_area.get_targetters()
		if targetters.size() == 0:
			pass
		else:
			parse_targetters(targetters)
			return
	else:
		if target:
			set_target(null, false)


func handle_movement() -> void:
	if target == null:
		check_wander_target()
		move_to_target()
		return
	
#	if actor.currently_firing:
##		rotate_while_firing()
#		move_to_target()
#		return
	
	if manager_in_sight:
		move_to_target()
		return
	
	if not back_up_timer.is_stopped():
		back_up()
		return
	
	if get_is_dodging():
		return
	
	if is_dodge_available():
		if detection_area.is_projectile_comin_for_me():
			dodge(choose_dodge_direction())
			return
	
	if target_slowed:
		move_to_target(false)
	else:
		check_movement_change()
		
		if move_forward:
			move_to_target(false)
		else:
			handle_strafe()


func handle_attacking() -> void:
	if not punch_anim_timer.is_stopped() or not target:
		return
	
	if manager_in_sight:
		if is_projectile_available():
			if fire_think_timer.is_stopped():
				fire_think_timer.wait_time = randf_range(0.1, 0.2)
				fire_think_timer.start()
				return
	
	if punch_think_timer.is_stopped():
		if check_punch_conditions():
			punch_think_timer.wait_time = randf_range(0.1, 0.2)
			punch_think_timer.start()
	
	if fire_think_timer.is_stopped():
		if check_fire_conditions():
			fire_think_timer.wait_time = randf_range(0.1, 0.2)
			fire_think_timer.start()

############################## Target Functions ############################################

func check_current_target() -> void:
	assert(target)
	
	if target.is_dead:
		set_target(null, false)
		return
	
	target_slowed = target.is_slowed
	
	if target.controller.is_fleeing:
		if is_projectile_available():
			return
		else:
			set_target(detection_area.get_lowest_health_opponent(), false)


func parse_targetters(targetters : Array[CharacterBody3D]) -> void:
	for dude in targetters:
		if dude is Manager:
			# Attempt to slather Manager and flee
			manager_in_sight = dude
			manager_flee_timer.start()
			return
		elif dude is Character:
			# Target almost dead; keep pummelling
			if target:
				if target.get_health() < 30:
					return
			# Better to switch to targetter?
			set_target(dude, false)


func _on_manager_flee_timer_timeout() -> void:
	manager_in_sight = null


func rotate_while_firing() -> void:
	if firing_rotation_timer.is_stopped():
#		face_enemy()
		firing_rotation_timer.start()
		turning_left = !turning_left
	
	if turning_left:
		set_y_rotation(rotation.y + 0.01)
	else:
		set_y_rotation(rotation.y - 0.01)

