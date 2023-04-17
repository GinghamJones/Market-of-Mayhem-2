extends Action


func run(actor : Character, controller : Controller) -> bool:
#	var pick_dir : int = randi() % 2
#	if pick_dir == 1:
#		controller.strafe_left()
#	else:
#		controller.strafe_right()
	controller.strafe_right()
	
	return true
