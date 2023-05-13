extends Action


func run(_actor : Character, controller : AIController) -> int:
	controller.move_to_target()
	return SUCCESS
