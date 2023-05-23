class_name AIController
extends Node3D

## Controller node intended to interface with Character functions.

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var balanced_module : PackedScene = preload("res://AI/Balanced AI/balanced_ai_module.tscn")

@onready var forget_timer : Timer = $ForgetTarget
@onready var detection_area : Area3D = $DetectionArea

var projectile_timer : Timer = null
var ai_module_children : Array = []
var cur_ai = null
var actor = null

var target : Character = null : set = set_target
var flee_target = null : set = set_flee_target

var fleeing : bool = false : set = set_fleeing, get = get_fleeing
var direction : Vector3 = Vector3.ZERO : set = set_direction, get = get_direction
var y_rotation : float = 0 : set = set_y_rotation, get = get_y_rotation
var velocity : Vector3 = Vector3.ZERO : set = set_velocity, get = get_velocity
var dodge_direction : Vector3 = Vector3.ZERO : get = get_dodge_direction

var did_i_fire : bool = false

signal y_rotation_computed
signal direction_computed
signal request_action
#signal request_punch
#signal requenst_fire
#signal request_block
#signal request_special


#func _process(delta: float) -> void:
#	pass
###################################### Main Run #####################################################

func run(delta : float):
	if actor:
		if did_i_fire:
			request_action.emit("StopFire")
			did_i_fire = false
		
		if actor.is_dead or actor.is_paused:
			return
		
		set_direction(Vector3.ZERO)
		
		for module in ai_module_children:
			module.run(self)
		
		
		
		direction_computed.emit(delta, direction)
#		actor.move_my_ass(delta, get_direction())

################################# Move Actions ######################################################

func move_to_target():
	set_direction((nav_agent.get_next_path_position() - actor.global_position).normalized())
	
	if target:
		set_nav_target(target.global_position)
		face_enemy()
	else:
		face_move_direction()

func flee_from_target():
	if flee_target:
		set_direction((nav_agent.get_next_path_position() - actor.global_position).normalized())
		set_nav_target(-target.position)
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


func stop_moving():
	actor.velocity = Vector3.ZERO


func face_enemy():
	if target:
		var new_direction = target.global_position - actor.global_position
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


#func use_special():
#	actor.use_special(


func fire():
#	actor._handle_firing()
	print("fire request received")
	request_action.emit("Fire")
	did_i_fire = true
#	request_action.emit("StopFire")


func dodge(new_dodge_direction : Vector3):
	face_enemy()
	dodge_direction = new_dodge_direction
#	actor.start_dodge(dodge_direction)
	request_action.emit("Dodge")


#################################### Checks #########################################################

func is_punch_available() -> bool:
	if actor.punch_timer.is_stopped():
		return true
	
	return false

func is_special_available() -> bool:
	var special_timer : Timer = actor.special_timer
	if special_timer.is_stopped():
		return true
	
	return false


func is_projectile_available() -> bool:
	if projectile_timer.is_stopped() and actor.get_ammo() > 0:
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
	var z_vector : Vector3 = actor.mesh.global_transform.basis.z
	var relative_pos : Vector3 = (actor.global_position - target.global_position).normalized()
	var dot : float = z_vector.dot(relative_pos)
#	print(dot)
	if dot > 0.8:
		return true
	else:
		return true


##################################### Setters #######################################################

func set_velocity(new_velocity : Vector3):
	velocity = new_velocity

func set_direction(new_direction : Vector3):
	direction = new_direction

func set_y_rotation(value : float):
#	y_rotation = lerp(y_rotation, value, 0.1)
	y_rotation = value
	emit_signal("y_rotation_computed", y_rotation)

func set_fleeing(what):
	fleeing = what

func set_detection(huh : bool):
	detection_area.monitoring = huh

func set_nav_target(new_target : Vector3):
	nav_agent.set_target_position(new_target)

func set_target(new_target : Character):
	if new_target == null:
		forget_timer.start()
		await forget_timer.timeout
		target = null
	else:
		target = new_target

func set_flee_target(new_target):
	if new_target == null:
		forget_timer.start()
		await forget_timer.timeout
		flee_target = null
		set_fleeing(false)
		
	flee_target = new_target
	set_fleeing(true)


##################################### Getters #######################################################
# Is this the best way of interfacing with actor?
func get_target_health() -> int:
	return target.get_health()

func get_actor_health() -> int:
	return actor.get_health()

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

func get_fleeing() -> bool:
	return fleeing



func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	set_velocity(safe_velocity)


func initiate(new_actor):
	# Be sure to instantiate an AIModule and set ai_module_children to its children
	actor = new_actor
	projectile_timer = actor.projectile_timer
	
	detection_area.set_actor(actor)
	y_rotation_computed.connect(Callable(actor, "set_y_rotation"))
	direction_computed.connect(Callable(actor, "move_my_ass"))
	request_action.connect(Callable(actor, "request_action"))
#	detection_area.add_exception(actor)


func die():
	detection_area.set_monitoring(false)
	detection_area.reset()
	target = null
	flee_target = null


func reset_ai():
#	incoming_projectile = null
	direction = Vector3.ZERO
	y_rotation = 0
	forget_timer.stop()
	detection_area.set_monitoring(true)
