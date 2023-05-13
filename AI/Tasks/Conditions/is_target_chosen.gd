extends Condition


func run(_actor : Character, controller : AIController) -> int:
	if controller.target:
		return SUCCESS
	else:
		return FAILURE
