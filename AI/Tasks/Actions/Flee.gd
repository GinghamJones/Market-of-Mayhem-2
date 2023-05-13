extends Action

func run(_actor : Character, controller : AIController) -> int:
	controller.flee_from_target()
	
	return SUCCESS
