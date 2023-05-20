class_name AIController
extends Node3D

## Controller node intended to interface with Character functions.

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var balanced_module : PackedScene = preload("res://AI/Balanced AI/balanced_ai_module.tscn")

@onready var forget_timer : Timer = $ForgetTarget
@onready var detection_area : Area3D = $DetectionArea

var ai_module_children : Array = []
var cur_ai_tree = null
var actor = null

var target : Character = null : set = set_target
var flee_target = null : set = set_flee_target

var fleeing : bool = false : set = set_fleeing, get = get_fleeing
var direction : Vector3 = Vector3.ZERO : set = set_direction, get = get_direction
var y_rotation : float = 0 : set = set_y_rotation, get = get_y_rotation
var velocity : Vector3 = Vector3.ZERO : set = set_velocity, get = get_velocity


func run():
	
	if actor:
		if actor.is_dead or actor.is_paused:
			return

		set_direction(Vector3.ZERO)
		# Complete the 2 checks to populate object arrays if objects are detected
#		detection_cast.check_shapecast()

		# Run children in AI Module but stop series if false is returned
#		cur_ai_tree.tick()

		for module in ai_module_children:
			module.run(self)


# Is this the best way of interfacing with actor?
func punch():
	actor.punch()

func is_punch_available() -> bool:
	if actor.punch_timer.is_stopped():
		return true
	
	return false
#func use_special():
#	actor.use_special()

func fire():
	actor._handle_firing()


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


func dodge(dodge_direction : Vector3):
	face_enemy()
	actor.start_dodge(dodge_direction)


func strafe_left():
	set_direction(-actor.transform.basis.x)
	face_enemy()
#	set_nav_target(-actor.transform.basis.x - 0.5)


func strafe_right():
	set_direction(actor.transform.basis.x)
	face_enemy()
#	set_nav_target(actor.transform.basis.x + 0.5)


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


func is_special_available() -> bool:
	var special_timer : Timer = actor.special_timer
	if special_timer.is_stopped():
		return true
	
	return false


func is_projectile_available() -> bool:
	var projectile_timer : Timer = actor.projectile_timer
	if projectile_timer.is_stopped() and actor.get_ammo() > 0:
		return true
	
	return false


func is_dodge_available() -> bool:
	if actor.dodge_cooldown.is_stopped():
		return true
	
	return false

func back_up():
	set_direction(transform.basis.z)

func set_velocity(new_velocity : Vector3):
	velocity = new_velocity

func get_velocity() -> Vector3:
	return velocity

func set_direction(new_direction : Vector3):
	direction = new_direction

func get_direction() -> Vector3:
	return direction

func get_is_dodging() -> bool:
	return actor.is_dodging

func get_y_rotation() -> float:
	return y_rotation

func set_y_rotation(value : float):
#	y_rotation = lerp(y_rotation, value, 0.1)
	y_rotation = value


func set_fleeing(what):
	fleeing = what

func get_fleeing() -> bool:
	return fleeing

#func forget_target():
##	await get_tree().physics_frame
#	target = null
#	flee_target = null

func set_detection(huh : bool):
	detection_area.monitoring = huh


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	set_velocity(safe_velocity)


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
	var vector_to_target : Vector3 = actor.global_position - target.global_position
	var dot : float = actor.velocity.dot(vector_to_target)
	
	if dot < 0.1:
		return true
	else:
		return true


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


func initiate(new_actor):
	# Be sure to instantiate an AIModule and set ai_module_children to its children
	actor = new_actor
	detection_area.set_actor(actor)
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


