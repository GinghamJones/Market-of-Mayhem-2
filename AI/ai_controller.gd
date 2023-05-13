class_name AIController
extends Node3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@export var ai_tree : Array[PackedScene]
@onready var forget_timer : Timer = $ForgetTarget
@onready var shapecast : ShapeCast3D = $ShapeCast3D

var cur_ai_tree = null
var actor = null

var opponents_in_sight : Array[Character]
var incoming_projectiles : Array[Projectile] = []
var target : Character = null
var flee_target : Character = null

var direction : Vector3 = Vector3.ZERO
var y_rotation : float = 0


func initiate(new_actor):
	actor = new_actor
	
	if actor is Manager:
		cur_ai_tree = ai_tree[1].instantiate()
	else:
		cur_ai_tree = ai_tree[0].instantiate()
		
	add_child(cur_ai_tree)
	cur_ai_tree.actor = actor
	cur_ai_tree.controller = self
	

func _physics_process(_delta):
	if actor:
		if not actor.is_dead or not actor.is_paused:
			direction = Vector3.ZERO
			#y_rotation = 0
			cur_ai_tree.tick()
			
			check_shapecast()


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
		# Just in case...
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
	y_rotation = lerp(y_rotation, value, 0.1)


func choose_target():
	var potential_target : Character = opponents_in_sight[0]
	var my_health : int = actor.character_stats.current_health
	for i in opponents_in_sight:
		var opponent_health : int = i.character_stats.current_health
		if i.character_stats.move_speed > actor.character_stats.move_speed:
			pass
		elif opponent_health - my_health < 10:
			potential_target = i
		elif opponent_health - my_health < 20:
			potential_target = i
		elif opponent_health - my_health < 40:
			potential_target = i
		else:
			potential_target = i
	
	target = potential_target


func check_opponent_proximities() -> bool:
	var cur_pos : Vector3 = actor.position
	var target_pos : Vector3 = target.position
	var cur_target_proximity : float = (target_pos - cur_pos).length()
#	print(cur_target_proximity)

	for i in opponents_in_sight:
		if i == target:
			pass
		else:
			var opponent_pos : Vector3 = i.position
			var new_opponent_proximity : float = (opponent_pos - cur_pos).length()
			var proximity_difference : float = cur_target_proximity - new_opponent_proximity
#			print(proximity_difference)
			if proximity_difference < 2:
				target = i
				return true
	
	return false

func forget_target():
	opponents_in_sight.erase(target)
	await get_tree().physics_frame
	target = null

func set_detection(huh : bool):
	$DetectionArea.monitoring = huh
	shapecast.enabled = huh

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	direction = safe_velocity


func check_shapecast():
	incoming_projectiles.clear()
	
	for i in shapecast.get_collision_count():
		var collider = shapecast.get_collider(i)
		if collider is Projectile:
			for projectile in incoming_projectiles:
				if collider == projectile:
					return
				else:
					incoming_projectiles.erase(projectile)
			
			incoming_projectiles.push_back(collider)
		elif collider is Character:
			if collider.character_stats.Team == actor.character_stats.Team or collider.is_dead:
				return
			else:
				for body in opponents_in_sight:
					if body == collider:
						return
					else:
						opponents_in_sight.erase(body)
				
				opponents_in_sight.push_back(collider)
				

func _on_detection_area_body_entered(body):
	if body is Manager:
		return
	
	if body is Character:
		# Check if sighted character is on same team
		if body.character_stats.Team == actor.character_stats.Team:
			return
		else:
			# If no opponents in sight, add sighted opponent
			if opponents_in_sight.size() == 0:
				opponents_in_sight.push_back(body)
			else:
				# Check if array already includes opponent
				for i in opponents_in_sight:
					if i == body:
						if i == target:
							forget_timer.stop()
						break
				
				opponents_in_sight.push_back(body)
	
#	elif body is Projectile:
#		if body.who_fired_me != actor:
#			incoming_projectile = body


func _on_detection_area_body_exited(body):
#	print("body exited")
#	if body is Projectile:
#		incoming_projectile = null
	if body is Character:
		if opponents_in_sight.has(body):
			if body == target:
				forget_timer.start()
			
			opponents_in_sight.erase(body)
#			print(str(body) + "successfully erased" + "     " + str(opponents_in_sight.size()))


func reset_ai():
	opponents_in_sight.clear()
	target = null
	flee_target = null
	incoming_projectiles.clear()
#	incoming_projectile = null
	direction = Vector3.ZERO
	y_rotation = 0
	forget_timer.stop()
