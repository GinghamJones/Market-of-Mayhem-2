extends Node3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var ai_tree = preload("res://Characters/Resources/AI/aggressive_ai.tscn").instantiate()

var actor : Character = null
var target : Character = null
var flee_target : Character = null
var incoming_projectile : Projectile = null
var direction : Vector3 = Vector3.ZERO
var y_rotation : float = 0


func initiate():
	add_child(ai_tree)
	ai_tree.actor = actor
	ai_tree.controller = self
	

func _physics_process(delta):
	if actor:
		if not actor.is_dead:
			direction = Vector3.ZERO
			y_rotation = 0
			ai_tree.tick()


func move_to_target():
	direction = (nav_agent.get_next_path_position() - actor.global_position).normalized()
	if target:
		face_enemy()
	else:
		set_y_rotation(atan2(-direction.x, -direction.z))


func flee_from_target():
	if flee_target:
		var test_direction = (actor.global_position - flee_target.global_position).normalized()
		nav_agent.set_velocity(test_direction)
		face_enemy()
	

func face_enemy():
	if target:
		var new_direction = target.global_position - actor.global_position
		var angle = atan2(-new_direction.x, -new_direction.z)
		set_y_rotation(angle)


func get_direction() -> Vector3:
	return direction


func get_y_rotation() -> float:
	return y_rotation

func set_y_rotation(value : float):
	y_rotation = value


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	direction = safe_velocity


func _on_detection_area_body_entered(body):
	if body is Character and target == null:
		var test_body : Character = body
		if test_body.character_stats.Team == actor.character_stats.Team:
			pass
		else:
			target = test_body
			TargetTracker.set_target(actor, target)
	elif body is Projectile:
		incoming_projectile = body


func _on_detection_area_body_exited(body):
	if body is Projectile:
		incoming_projectile = null
	if body == target:
		TargetTracker.remove_target(actor)
		target = null
