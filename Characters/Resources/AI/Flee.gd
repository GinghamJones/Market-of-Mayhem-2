extends Action

func run(actor, controller) -> bool:
	controller.flee_from_target()
	
	return true
