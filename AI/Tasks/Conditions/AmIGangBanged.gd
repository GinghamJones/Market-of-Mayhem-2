extends Condition


func run(_actor : Character, controller : AIController) -> int:
	if controller.opponents_in_sight.size() > 3:
		controller.flee_target = controller.opponents_in_sight[0]
		return SUCCESS
	else:
		# How performant is this??
		controller.flee_target = null
		return FAILURE
