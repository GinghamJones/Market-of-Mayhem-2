extends Action


func run(actor, controller : AIController) -> int:
	controller.check_opponent_proximities()
	return SUCCESS
	

