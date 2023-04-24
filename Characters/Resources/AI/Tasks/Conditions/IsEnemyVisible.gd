extends Condition


func run(_actor : Character, controller : AIController) -> int:
#	if controller.opponents_in_sight.size() > 0:

	if controller.opponents_in_sight.size() > 0:
		return SUCCESS
	
	return FAILURE
