extends Condition

func run(actor, controller : AIController) -> int:
	if controller.has_closer_target():
		return FAILURE
	else:
		return SUCCESS
