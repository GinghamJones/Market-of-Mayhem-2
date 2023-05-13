extends Action


func run(actor, controller : AIController) -> int:
	controller.forget_target()
	return SUCCESS
