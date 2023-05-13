extends Condition


func run(actor, controller : AIController) -> int:
	if controller.target.is_dead:
		return FAILURE
	
	return SUCCESS
