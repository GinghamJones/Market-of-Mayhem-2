class_name AIController
extends Node3D

## Controller node intended to interface with Character functions.

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D

@onready var detection_area : DetectionArea = $DetectionArea

@onready var strafe_dir_timer : Timer = $Node/StrafeDirTimer
@onready var back_up_timer: Timer = $Node/BackUpTimer
@onready var change_movement_timer: Timer = $Node/ChangeMovementTimer
@onready var flee_timer: Timer = $Node/FleeTimer
@onready var punch_think_timer: Timer = $Node/PunchThinkTimer
@onready var punch_anim_timer: Timer = $Node/PunchAnimTimer
@onready var fire_think_timer: Timer = $Node/FireThinkTimer
@onready var target_think_timer: Timer = $Node/TargetThinkTimer
@onready var forget_target: Timer = $Node/ForgetTarget

@onready var target_text: Label = $CanvasLayer/Target
@onready var movement_text: Label = $CanvasLayer/Movement
@onready var attacking_text: Label = $CanvasLayer/Attacking

var projectile_timer : Timer = null
var actor : Character = null
var controller_positioner : Node3D = null

var target : Character = null
var flee_target : Character = null
#var frames_till_run : int = randi_range(3, 10)

var direction : Vector3 = Vector3.ZERO : set = set_direction, get = get_direction
var y_rotation : float = 0 : set = set_y_rotation, get = get_y_rotation
var velocity : Vector3 = Vector3.ZERO : set = set_velocity, get = get_velocity
var dodge_direction : Vector3 = Vector3.ZERO : get = get_dodge_direction
var strafe_dir : int = 0   # 0 = right, 1 = left
var distance_to_target : float = 0.0

var too_many_dudes : bool = false
var is_fleeing : bool = false
var move_forward : bool = true
var did_i_fire : bool = false
var projectile_available : bool = true

@export var RANGE_RADIUS : float = 20

signal y_rotation_computed
signal direction_computed
signal request_action


################################# Move Actions ######################################################

func move_to_target(is_using_ranged : bool = false):
	set_direction((nav_agent.get_next_path_position() - actor.global_position).normalized())
	actor.move_direction = 1
	if is_fleeing:
		return
	
	if target:
		if is_using_ranged:
			set_nav_target(target.global_position * RANGE_RADIUS)
		else:
			set_nav_target(target.global_position)
		face_enemy()
	else:
		face_move_direction()


func flee():
	#var new_flee_target : Character = detection_area.get_closest_opponent()
	#if not new_flee_target:
		#set_is_fleeing(false)
	#else:
		#flee_target = new_flee_target
	set_direction((actor.global_position - flee_target.global_position).normalized())
#	move_to_target()
	face_enemy()


func strafe_left():
	set_direction(-actor.transform.basis.x)
	face_enemy()
#	set_nav_target(-actor.transform.basis.x - 0.5)


func strafe_right():
	set_direction(actor.transform.basis.x)
	face_enemy()
#	set_nav_target(actor.transform.basis.x + 0.5)


func back_up():
	set_direction(transform.basis.z)
	actor.move_direction = -1


func stop_moving():
	actor.velocity = Vector3.ZERO
	actor.move_direction = 0


func face_enemy():
	if target:
		var new_direction = target.global_position - actor.global_position
		var angle = atan2(-new_direction.x, -new_direction.z)
		set_y_rotation(angle)
	elif flee_target:
		var new_direction = flee_target.global_position - actor.global_position
		var angle = atan2(-new_direction.x, -new_direction.z)
		set_y_rotation(angle)
	else:
		# Just in case...
		face_move_direction()


func face_move_direction():
	var cur_direction : Vector3 = get_direction()
	var new_rotation : float = atan2(-cur_direction.x, -cur_direction.z)
	set_y_rotation(new_rotation)


################################ Combat Actions #####################################################

func punch():
	request_action.emit("Attack")
	punch_anim_timer.start()
	back_up_timer.start()

#func use_special():
#	actor.use_special(


func fire():
	request_action.emit("Fire")
	did_i_fire = true
#	request_action.emit("StopFire")


func dodge(new_dodge_direction : Vector3):
	face_enemy()
	dodge_direction = new_dodge_direction
	request_action.emit("Dodge")


#################################### Checks #########################################################

func is_punch_available() -> bool:
	if punch_anim_timer.is_stopped():
		return true
	
	return false


func is_special_available() -> bool:
#	var special_timer : Timer = actor.special_timer
	if actor.special_timer.is_stopped():
		return true
	
	return false


func is_projectile_available() -> bool:
	if projectile_timer and actor.attack_component.current_ammo > 0:
		return true
	
	return false


func is_dodge_available() -> bool:
	if actor.dodge_cooldown.is_stopped():
		return true
	
	return false


func is_target_in_special_range() -> bool:
	if target.global_position.length() - actor.global_position.length() < 0.5:
			return true
	else:
		return false


func is_target_in_punch_range() -> bool:
	if (target.global_position - actor.global_position).length() < 1.3:
		return true
	else:
		return false


func is_target_aimed_at() -> bool:
	var angle1 : Vector3 = actor.global_transform.basis.z
	var angle3 : Vector3 = (actor.global_position - target.global_position).normalized()
	var angle : float = angle1.dot(angle3)

	if angle > 0.97:
		return true
	else:
		return false


func is_health_too_low(new_target : Character) -> bool:
	if new_target.get_health() - get_actor_health() > 50:
		return true
	
	return false


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

##################################### Setters #######################################################

func set_velocity(new_velocity : Vector3):
	velocity = new_velocity

func set_direction(new_direction : Vector3):
	direction = new_direction
#	actor.move_direction = direction

func set_y_rotation(value : float):
#	y_rotation = lerp(y_rotation, value, 0.1)
	rotation.y = value
	emit_signal("y_rotation_computed", rotation.y)

func set_detection(huh : bool):
	detection_area.monitoring = huh

func set_nav_target(new_target : Vector3):
	nav_agent.set_target_position(new_target)

func set_target(new_target : Character, is_urgent : bool):
	if is_urgent:
		target = new_target
	else:
		if forget_target.is_stopped():
			forget_target.start()
		await forget_target.timeout
		target = new_target


func set_is_fleeing(value) -> void:
	if value == false and flee_timer.is_stopped():
		print("flee timer started")
		flee_timer.start()
	elif value == true:
		is_fleeing = true

func stop_fleeing() -> void:
	is_fleeing = false
	flee_target = null


##################################### Getters #######################################################
# Is this the best way of interfacing with actor?
func get_target_health() -> int:
	return target.health_component.current_health

func get_actor_health() -> int:
	return actor.health_component.current_health

func get_actor_speed() -> float:
	return actor.get_speed()

func get_target_pos() -> Vector3:
	return target.global_position

func get_actor_pos() -> Vector3:
	return actor.global_position

func get_dodge_direction() -> Vector3:
	return dodge_direction

func get_velocity() -> Vector3:
	return velocity

func get_direction() -> Vector3:
	return direction

func get_is_dodging() -> bool:
	return actor.is_dodging

func get_y_rotation() -> float:
	return y_rotation

############################ Misc #########################################################
func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	set_velocity(safe_velocity)


func initiate(new_actor):
	# Be sure to instantiate an AIModule and set ai_module_children to its children
	actor = new_actor
	projectile_timer = actor.attack_component.projectile_timer
	controller_positioner = actor.get_node("ControllerPositioner")
	
	detection_area.set_actor(actor)
	y_rotation_computed.connect(Callable(actor, "set_y_rotation"))
	direction_computed.connect(Callable(actor, "move_my_ass"))
	request_action.connect(Callable(actor, "request_action"))
	
	if actor is Florist:
		nav_agent.set_navigation_layer_value(2, true)
	elif actor is Produce:
		nav_agent.set_navigation_layer_value(3, true)
	elif actor is MeatDude:
		nav_agent.set_navigation_layer_value(4, true)
	elif actor is Freight:
		nav_agent.set_navigation_layer_value(5, true)
	elif actor is KitchenDude:
		nav_agent.set_navigation_layer_value(6, true)
	elif actor is Baker:
		nav_agent.set_navigation_layer_value(7, true)
	elif actor is Cashier:
		nav_agent.set_navigation_layer_value(8, true)
	
	# Because a target was already set for some reason?
	set_nav_target(actor.spawn_point)


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
			if random_position < Vector3(1, 0, 1) and random_position > Vector3(-1, 0, -1):
				set_nav_target(Vector3(1000, 234, 2343))
			else:
				set_nav_target(random_position)
			if nav_agent.is_target_reachable():
				break


func check_movement_change() -> void:
	if change_movement_timer.is_stopped():
		move_forward = !move_forward
		if move_forward:
			change_movement_timer.wait_time = randf_range(1.5, 2.0)
		else:
			change_movement_timer.wait_time = randf_range(0.2, 0.4)
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


func die():
	detection_area.set_monitoring(false)
	detection_area.reset()
	target = null
	is_fleeing = false
	flee_target = null


func reset_ai():
#	incoming_projectile = null
	direction = Vector3.ZERO
	y_rotation = 0
	forget_target.stop()
	detection_area.set_monitoring(true)
