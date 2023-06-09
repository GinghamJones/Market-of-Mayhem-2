extends Area3D

#@onready var line_of_sight : RayCast3D = $LineOfSight

var opponents_in_sight : Array[Character] = []
var projectiles_in_sight : Array[Projectile] = []
var manager_in_sight : Manager = null

# Eh, do you think this is okay, ma?
var actor = null


#func get_lowest_health_opponent() -> Character:
#	if opponents_in_sight.size() == 0:
#		return null
#
#	var potential_target : Character = opponents_in_sight[0]
#	var target_health : int = potential_target.get_health()
#
#	for dude in opponents_in_sight:
#		# Just in case the array hasn't been updated...
#		if dude.is_dead:
#			pass
#		else:
#			var new_target_health : int = dude.get_health()
#			if new_target_health < target_health:
#				potential_target = dude
#
#	return potential_target


func am_i_facing_target(target_position : Vector3) -> bool:
	var dot = actor.global_position.dot(target_position)
	if dot > 0.9:
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


func get_manager_in_sight() -> Manager:
	return manager_in_sight


func get_opponents_in_sight() -> Array[Character]:
	return opponents_in_sight


func get_dudes_in_sight() -> int:
	return opponents_in_sight.size()


func get_projectiles_in_sight() -> Array[Projectile]:
	return projectiles_in_sight


func set_actor(new_actor):
	actor = new_actor


func reset():
	opponents_in_sight = []
	projectiles_in_sight = []
	manager_in_sight = null


func _on_body_entered(body: Node3D) -> void:
	print("body entered")
	if body == actor:
		return
	
	if body is Character:
		if not check_line_of_sight(to_local(body.global_position)):
			return
		if body.is_dead:
			return
		else:
			opponents_in_sight.push_back(body)


func _on_body_exited(body: Node3D) -> void:
	if body is Character:
		if opponents_in_sight.has(body):
			opponents_in_sight.erase(body)
		return


func check_line_of_sight(body_pos : Vector3) -> bool:
	var line_of_sight : RayCast3D = RayCast3D.new()
	add_child(line_of_sight)
	line_of_sight.position = position
	
	line_of_sight.set_collision_mask_value(1, true)
	line_of_sight.set_collision_mask_value(2, true)
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
