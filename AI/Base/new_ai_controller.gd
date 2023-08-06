extends Node3D

@onready var detection_area : DetectionArea = $DetectionArea
@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var target_think_timer : Timer = $Node/TargetThinkTimer
@onready var punch_think_timer : Timer = $Node/PunchThinkTimer
@onready var fire_think_timer : Timer = $Node/FireThinkTimer

var actor : Character = null

var did_i_fire : bool = false
var can_fire : bool = true
var can_punch : bool = true
var is_using_punches : bool = false
var wandering : bool = true
var direction : Vector3 = Vector3()
var target : Character = null

const RANGE_RADIUS : float = 5.0

signal request_action


func run(delta : float) -> void:
	if did_i_fire:
		request_action.emit("StopFire")
		did_i_fire = false
#	global_position = controller_positioner.global_position
	set_direction(Vector3.ZERO)

	handle_target_selection()
	handle_movement()
	handle_attacking()


func handle_target_selection() -> void:
	var num_in_sight : int = detection_area.get_num_in_sight()
	
	if num_in_sight > 3:
		pass
	elif num_in_sight > 0:
		pass
	else:
		set_wandering(true)
		check_wander_target()



func handle_movement() -> void:
	if wandering:
		move_to_target()


func handle_attacking() -> void:
	pass


func move_to_target() -> void:
	set_direction((nav_agent.get_next_path_position() - actor.global_position).normalized())
	if target:
		if is_using_punches:
			set_nav_target(target.global_position * 1.1) # Multiply by 1.1 for breathing space
		else:
			set_nav_target(target.global_position * RANGE_RADIUS)


func set_direction(new_direction : Vector3) -> void:
	direction = new_direction


func get_direction() -> Vector2:
	# Character takes a Vector2 for movement
	return Vector2(direction.x, direction.z)

func set_nav_target(new_target : Vector3) -> void:
	nav_agent.set_target_position(new_target)


func set_wandering(value : bool) -> void:
	if wandering != value:
		wandering = value


func check_wander_target() -> void:
	print("checking wander target")
	print(nav_agent.get_final_position())
	if nav_agent.is_navigation_finished():
		print("nav finished")
		while(true):
			var radius : float = 50.0
			var random_position = Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))
			if random_position < Vector3(1, 0, 1) and random_position > Vector3(-1, 0, -1):
				set_nav_target(Vector3(1000, 234, 2343))
			else:
				set_nav_target(random_position)
			if nav_agent.is_target_reachable():
				break


func initiate(new_actor):
	# Be sure to instantiate an AIModule and set ai_module_children to its children
	actor = new_actor
	
	detection_area.set_actor(actor)
#	y_rotation_computed.connect(Callable(actor, "set_y_rotation"))
#	direction_computed.connect(Callable(actor, "move_my_ass"))
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

