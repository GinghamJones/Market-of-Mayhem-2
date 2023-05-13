extends Condition

var threshold : float = 0.7

func run(actor : Character, controller : AIController) -> int:
	var projectiles : Array[Projectile] = controller.incoming_projectiles
	for item in projectiles:
		if item.is_active:
			var vector_to_charaacter = (actor.global_position - item.global_position).normalized()
			var projectile_velocity = item.linear_velocity
			projectile_velocity = projectile_velocity.normalized()
			var dot : float = projectile_velocity.dot(vector_to_charaacter)
			if dot > threshold:
				return SUCCESS

	return FAILURE
