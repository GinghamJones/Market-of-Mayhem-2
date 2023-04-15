extends Action


func run(actor : Character, controller) -> bool:
	actor.use_super_move()
	return true
