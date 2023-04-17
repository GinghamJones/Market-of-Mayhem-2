extends Action


func run(actor : Character, controller : Controller) -> bool:
	controller.move_to_target()
	return true
