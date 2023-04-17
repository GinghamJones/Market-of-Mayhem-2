extends Condition

var threshold : float = 0.7

func run(actor : Character, controller : Controller) -> bool:
	if controller.incoming_projectile and controller.incoming_projectile.is_active:
		var vector_to_character = (actor.global_position - controller.incoming_projectile.global_position).normalized()
		var projectile_velocity = controller.incoming_projectile.linear_velocity
		projectile_velocity = projectile_velocity.normalized()
		var dot : float = projectile_velocity.dot(vector_to_character)
		if dot > threshold:
			print(dot)
			return true
		else:
			return false

	return false
