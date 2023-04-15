extends Action


func run(actor : Character, controller) -> bool:
	controller.move_to_target()

	return true
