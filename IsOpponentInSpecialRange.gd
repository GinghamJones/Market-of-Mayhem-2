extends Condition

func run(actor : Character, controller) -> bool:
	if controller.target.global_position.length() - actor.global_position.length() < 0.5:
		return true
	else:
		return false
