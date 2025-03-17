class_name DetectionArea
extends Area3D

#@onready var line_of_sight : RayCast3D = $LineOfSight

var opponents_in_sight : Array[Character] = []
var projectiles_in_sight : Array[Projectile] = []
var manager_in_sight : Manager = null

# Eh, do you think this is okay, ma?
var actor : Character = null


func populate_opponents_in_sight():
	var start_time : int = Time.get_ticks_usec()
	for thing in get_overlapping_bodies():
		if thing is Character:
			if thing.get_team() == actor.get_team():
				pass
			else:
				if check_line_of_sight(to_local(thing.global_position)):
					opponents_in_sight.push_back(thing)
		elif thing is Manager:
			if check_line_of_sight(to_local(thing.global_position)):
				manager_in_sight = thing
	var end_time : int = Time.get_ticks_usec()
	print("Populate took %s us" % (end_time-start_time))


func get_lowest_health_opponent() -> Character:
	if opponents_in_sight.size() == 0:
		return null
	
#	var potential_target : Character = opponents_in_sight[0]
#	var target_health : int = potential_target.get_health()
	
#	for thing in get_overlapping_bodies():
#		if thing is Character:
#			if thing.get_team() == actor.get_team():
#				pass
#			else:
#				opponents_in_sight.push_back(thing)
	
	var potential_target : Character = opponents_in_sight[0]
	var target_health : int = potential_target.get_health()
	for dude in opponents_in_sight:
		if dude.is_dead:
			pass
		else:
			var new_target_health : int = dude.get_health()
			if new_target_health < target_health:
				potential_target = dude
#	for dude in opponents_in_sight:
#		# Just in case the array hasn't been updated...
#		if dude.is_dead:
#			pass
#		else:
#			var new_target_health : int = dude.get_health()
#			if new_target_health < target_health:
#				potential_target = dude

	return potential_target


func am_i_facing_target(target_position : Vector3) -> bool:
	var dot = actor.global_position.dot(target_position)
	if dot > 0.9:
		return true
	
	return false


func is_projectile_comin_for_me() -> bool:
	if projectiles_in_sight.size() < 1:
		return false
	
	var threshold : float = 0.7
	
	for item in projectiles_in_sight:
		if item.is_active:
			var vector_to_charaacter = (actor.global_position - item.global_position).normalized()
			var projectile_velocity = item.linear_velocity
			projectile_velocity = projectile_velocity.normalized()
			var dot : float = projectile_velocity.dot(vector_to_charaacter)
			if dot > threshold:
				return true
	
	return false


func get_closest_opponent() -> Character:
	var cur_pos : Vector3 = actor.position
#	print(cur_target_proximity)
	var previous_proximity : float = 50.0
	var new_target : Character = null
	
	if opponents_in_sight.size() == 0:
		return new_target
	
	for dude in opponents_in_sight:
		# Just in case the array hasn't been updated...
		if dude.is_dead:
			pass
		else:
			var opponent_pos : Vector3 = dude.position
			var new_opponent_proximity : float = (opponent_pos - cur_pos).length()

	#			print(proximity_difference)
			if new_opponent_proximity < previous_proximity:
				previous_proximity = new_opponent_proximity
				new_target = dude
	
	return new_target


func get_targetters() -> Array[CharacterBody3D]:
	var targetters : Array[CharacterBody3D] = []
	for dude in opponents_in_sight:
		if dude.controller.target == actor:
			targetters.push_back(dude)
	
	return targetters


func get_manager_in_sight() -> Manager:
	return manager_in_sight


func get_opponents_in_sight() -> Array[Character]:
	return opponents_in_sight


func get_num_in_sight() -> int:
	populate_opponents_in_sight()
	return opponents_in_sight.size()


#func clear_opponents_in_sight() -> void:
#	opponents_in_sight.clear()

func get_projectiles_in_sight() -> Array[Projectile]:
	return projectiles_in_sight


func set_actor(new_actor):
	actor = new_actor


func reset():
	opponents_in_sight = []
	projectiles_in_sight = []
	manager_in_sight = null


#func check_area() -> Array[Character]:

#func _on_body_entered(body: Node3D) -> void:
#	if body == actor:
#		return
#
#	if body is Character:
#		if not check_line_of_sight(to_local(body.global_position)):
#			return
#		if actor.character_stats.Team == body.character_stats.Team or body.is_dead:
#			return
#		else:
#			opponents_in_sight.push_back(body)
#	elif body is Manager:
#		manager_in_sight = body
#		return
#	elif body is Projectile:
#		if body.is_active:
#			projectiles_in_sight.push_back(body)
#
#		return
#
#
#func _on_body_exited(body: Node3D) -> void:
#	if body is Character:
#		if opponents_in_sight.has(body):
#			opponents_in_sight.erase(body)
#		return
#	elif body is Projectile:
#		if projectiles_in_sight.has(body):
#			projectiles_in_sight.erase(body)
#		return
#	elif body is Manager:
#		manager_in_sight = null
#		return


func check_line_of_sight(body_pos : Vector3) -> bool:
	var line_of_sight : RayCast3D = RayCast3D.new()
	add_child(line_of_sight)
	line_of_sight.position = position
	
	line_of_sight.set_collision_mask_value(1, true)
	line_of_sight.set_collision_mask_value(2, true)
	# Enable collision with spawn-area barriers
	for i in 7:
		line_of_sight.set_collision_mask_value(i + 6, true)
	line_of_sight.collide_with_areas = true
	line_of_sight.collide_with_bodies = true
	line_of_sight.enabled = true
	
	# Determine where to point raycast
	var vector_to_char : Vector3 = body_pos - position
	vector_to_char = vector_to_char.normalized()
	var distance : float = (position - body_pos).length()
	line_of_sight.target_position = vector_to_char * distance

	var collider
	while(true):
		line_of_sight.force_raycast_update()
		collider = line_of_sight.get_collider()
		if collider == actor:
			line_of_sight.add_exception(collider)
		else:
			break
	line_of_sight.queue_free()
	
	if collider is CharacterBody3D:
		return true
	else:
		return false
