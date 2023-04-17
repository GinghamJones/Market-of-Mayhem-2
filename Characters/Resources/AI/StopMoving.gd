extends Action


func run(actor : Character, controller : Controller) -> bool:
	controller.flee_from_target()
	return true
