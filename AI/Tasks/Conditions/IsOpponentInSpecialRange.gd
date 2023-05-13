extends Condition

func run(actor : Character, controller) -> int:
	if controller.target.global_position.length() - actor.global_position.length() < 0.5:
		return SUCCESS
	else:
		return FAILURE
