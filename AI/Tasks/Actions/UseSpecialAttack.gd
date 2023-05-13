extends Action


func run(actor : Character, _controller : AIController) -> int:
	actor.use_super_move()
	return SUCCESS
