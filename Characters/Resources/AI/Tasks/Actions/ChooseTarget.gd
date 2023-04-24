extends Action


func run(_actor : Character, controller : AIController) -> int:
	controller.choose_target()
	return SUCCESS
