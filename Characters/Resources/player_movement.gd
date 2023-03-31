extends Resource

func get_velocity(speed, acceleration, velocity, direction) -> Vector3:
	var target_velocity : Vector3 = direction * speed
	
	var new_velocity : Vector3
	new_velocity = lerp(new_velocity, target_velocity, acceleration)
	return new_velocity
