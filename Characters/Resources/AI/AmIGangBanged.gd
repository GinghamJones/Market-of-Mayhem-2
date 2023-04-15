extends Condition


func run(actor, controller) -> bool:
	if TargetTracker.get_target_count(actor) > 1:
		controller.flee_target = TargetTracker.get_targetter(actor)
		controller.nav_agent.set_target_position(controller.flee_target.global_position)
		return true
	else:
		controller.flee_target = null
		return false
