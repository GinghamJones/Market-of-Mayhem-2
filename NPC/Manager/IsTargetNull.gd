extends Condition

func run(actor : , controller : AIController) -> int:
	if actor.target == null:
		return SUCCESS
	
	return FAILURE
