extends Condition


func run(actor : Character, controller) -> bool:
	if (controller.target.global_position - actor.global_position).length() < 2.0:
		return true
	else:
		return false
