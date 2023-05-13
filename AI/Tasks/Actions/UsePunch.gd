extends Action

func run(actor : Character, _controller : AIController) -> int:
	actor.punch()
	return SUCCESS
