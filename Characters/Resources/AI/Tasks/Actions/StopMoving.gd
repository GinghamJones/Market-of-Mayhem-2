extends Action


func run(_actor : Character, controller : AIController) -> int:
	print("i stopped moving")
	controller.stop_moving()
	return SUCCESS
