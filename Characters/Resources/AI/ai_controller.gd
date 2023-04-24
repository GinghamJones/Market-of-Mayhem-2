class_name AIController
extends Node3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var ai_tree = preload("res://Characters/Resources/AI/aggressive_ai.tscn").instantiate()

var actor : Character = null
var opponents_in_sight : Array[Character]
var target : Character = null
var flee_target : Character = null
var incoming_projectile : Projectile = null
var direction : Vector3 = Vector3.ZERO
var y_rotation : float = 0


func initiate():
	add_child(ai_tree)
	ai_tree.actor = actor
	ai_tree.controller = self
	

func _physics_process(_delta):
	if actor:
		if not actor.is_dead:
			direction = Vector3.ZERO
			#y_rotation = 0
			ai_tree.tick()
	else:
		pass


func move_to_target():
	direction = (nav_agent.get_next_path_position() - actor.global_position).normalized()
	if target:
		nav_agent.set_target_position(target.global_position)
		face_enemy()
	else:
		face_move_direction()


func flee_from_target():
	if target:
		nav_agent.set_target_position(-flee_target.global_position)
		direction = (nav_agent.get_next_path_position() - actor.global_position).normalized()
		face_enemy()


func dodge(dodge_direction : Vector3):
	face_enemy()
	actor.start_dodge(dodge_direction)


func strafe_left():
	face_enemy()
	direction = -actor.transform.basis.x

func strafe_right():
	face_enemy()
	direction = actor.transform.basis.x


func stop_moving():
	actor.velocity = Vector3.ZERO


func face_enemy():
	if target:
		var new_direction = target.global_position - actor.global_position
		var angle = atan2(-new_direction.x, -new_direction.z)
		set_y_rotation(angle)
	else:
		face_move_direction()


func face_move_direction():
	var new_rotation : float = atan2(-direction.x, -direction.z)
	set_y_rotation(new_rotation)


func back_up():
	direction = transform.basis.z


func get_direction() -> Vector3:
	return direction


func get_y_rotation() -> float:
	return y_rotation

func set_y_rotation(value : float):
	y_rotation = value


func choose_target():
	var potential_target : Character = opponents_in_sight[0]
	for i in opponents_in_sight:
		if i.character_stats.current_health < potential_target.character_stats.current_health:
			potential_target = i
	
	target = potential_target


func forget_target():
	opponents_in_sight.erase(target)
	target = null



func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	direction = safe_velocity


func _on_detection_area_body_entered(body):
	if body is Character and target == null:
		var test_body : Character = body
		# Check if sighted character is on same team
		if test_body.character_stats.Team == actor.character_stats.Team:
			pass
		else:
			# If no opponents in sight, add sighted opponent
			if opponents_in_sight.size() == 0:
				opponents_in_sight.push_back(test_body)
				print(opponents_in_sight)
				print(opponents_in_sight.size())
			else:
				# Check if array already includes opponent
				for i in opponents_in_sight:
					if i == test_body:
						if i == target:
							$ForgetTarget.stop()
						break
				
				opponents_in_sight.push_back(test_body)
				
#				if not target:
#					target = test_body
	#			TargetTracker.set_target(actor, target)
	
	elif body is Projectile:
		if body.who_fired_me != actor:
			incoming_projectile = body


func _on_detection_area_body_exited(body):
	if body is Projectile:
		incoming_projectile = null
	if body is Character:
		if opponents_in_sight.has(body):
			if body == target:
				$ForgetTarget.start()
			else:
				opponents_in_sight.erase(body)
#	if body == target:
##		TargetTracker.remove_target(actor)
#		target = null

