extends ShapeCast3D

var opponents_in_sight : Array[Character] = []
var projectiles_in_sight : Array[Projectile] = []
var manager_in_sight : Manager = null

# Eh, do you think this is okay, ma?
var actor : Character = null


##################################################################################################################
################################# Check objects in ShapeCast #####################################################

func check_shapecast():
	# How performant is this???
	opponents_in_sight.clear()
	projectiles_in_sight.clear()
	
	for i in get_collision_count():
		var thing = get_collider(i)
		if thing is Character:
			if actor.character_stats.Team == thing.character_stats.Team:
				pass
			else:
				opponents_in_sight.push_back(thing)
		elif thing is Manager:
			manager_in_sight = thing
		elif thing is Projectile:
			projectiles_in_sight.push_back(thing)

	
#	if opponents_in_sight.size() > 0:
#		return true
#	else:
#		return false


#func check_projectiles():
#	# How performant is this???
#	projectiles_in_sight.clear()
#
#	for i in get_collision_count():
#		var thing = get_collider(i)
#		if thing is Projectile:
#			projectiles_in_sight.push_back(thing)
		
#	if projectiles_in_sight.size() > 0:
#		return true
#	else:
#		return false
		
##################################################################################################################
##################################################################################################################


#func get_fresh_target() -> Character:
#	if check:
#		return get_closest_opponent()
#
#	return null


func get_lowest_health_opponent() -> Character:
	var potential_target : Character = opponents_in_sight[0]
	var target_health : int = potential_target.get_health()

	for dude in opponents_in_sight:
		var new_target_health : int = dude.get_health()
		if new_target_health < target_health:
			potential_target = dude

	return potential_target



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
	
	for dude in opponents_in_sight:
		var opponent_pos : Vector3 = dude.position
		var new_opponent_proximity : float = (opponent_pos - cur_pos).length()

#			print(proximity_difference)
		if new_opponent_proximity < previous_proximity:
			previous_proximity = new_opponent_proximity
			new_target = dude
	
	return new_target


func am_i_targetted() -> Character:
	for dude in opponents_in_sight:
		if dude.controller.target == actor:
			return dude
	
	return null

func get_manager_in_sight() -> Manager:
	return manager_in_sight


func get_opponents_in_sight() -> Array[Character]:
	return opponents_in_sight


func is_anyone_in_sight() -> bool:
	if opponents_in_sight.size() == 0:
		return false
	
	return true


func get_projectiles_in_sight() -> Array[Projectile]:
	return projectiles_in_sight


func set_actor(new_actor):
	actor = new_actor