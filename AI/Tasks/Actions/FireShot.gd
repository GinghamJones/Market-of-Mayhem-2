extends Action


func run(actor : Character, _controller : AIController) -> int:
	actor._handle_firing()
	return SUCCESS
