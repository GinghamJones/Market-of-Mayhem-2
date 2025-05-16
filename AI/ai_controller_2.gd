class_name AIController2
extends Node3D

var actor : Character = get_parent()
@onready var actions: Actions = $Actions
@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var detection_area : Area3D = $DetectionArea
var current_action : String
var wander_target : Vector3
var target : Character
var move_dir : Vector3

signal request_action


func run(delta: float) -> void:
	var action : String = actions.get_best_action()
	if action == current_action:
		return
	
	current_action = action
	
	if action == "wander":
		wander()
	elif action == "chase":
		chase()
	elif action == "punch":
		punch()
	elif action == "dodge":
		dodge()
	elif action == "fire":
		fire()
	elif action == "retreat":
		retreat()
	else:
		print("Something went wrong: %s has been requested" % action)
	
	actor.move_my_ass(delta, move_dir)


func wander() -> void:
	if wander_target == Vector3.ZERO:
		while true:
			var r : RandomNumberGenerator = RandomNumberGenerator.new()
			var new_target : Vector3 = Vector3(r.randf_range(-10, 10), r.randf_range(-10, 10), r.randf_range(-10, 10))
			nav_agent.target_position = new_target
			if nav_agent.is_target_reachable():
				wander_target = new_target
				break
		
	set_direction(wander_target)


func chase() -> void:
	pass


func punch() -> void:
	pass


func dodge() -> void:
	pass


func fire() -> void:
	pass


func retreat() -> void:
	pass


func set_direction(target_position : Vector3) -> void:
	var direction : Vector3 = (nav_agent.get_next_path_position() - actor.global_position).normalized()
	move_dir = direction


func is_projectile_incoming() -> bool:
	# A suitable hack for now #
	var objects = detection_area.get_overlapping_bodies()
	for object in objects:
		if object is Projectile:
			return true
	
	return false


func is_target_visible() -> bool:
	# Used to determine if known target is behind obstacle, thus not visible
	var raycast : RayCast3D = RayCast3D.new()
	raycast.global_position = actor.global_position + Vector3(0, 1.0, 0)
	raycast.target_position = target.global_position - global_position
	raycast.collide_with_bodies = true
	if raycast.is_colliding():
		var collider : PhysicsBody3D = raycast.get_collider()
		if collider.is_in_group("Level"):
			return false
	
	return true


func initiate(new_actor):
	# Be sure to instantiate an AIModule and set ai_module_children to its children
	actor = new_actor
	#projectile_timer = actor.attack_component.projectile_timer
	#controller_positioner = actor.get_node("ControllerPositioner")
	
	#detection_area.set_actor(actor)
	#y_rotation_computed.connect(Callable(actor, "set_y_rotation"))
	#direction_computed.connect(Callable(actor, "move_my_ass"))
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
	#set_nav_target(actor.spawn_point)
