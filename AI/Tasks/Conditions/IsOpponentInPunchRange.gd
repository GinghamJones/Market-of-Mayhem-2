extends Condition


func run(actor : Character, controller) -> int:
	if (controller.target.global_position - actor.global_position).length() < 1.3:
		return SUCCESS
	else:
		return FAILURE