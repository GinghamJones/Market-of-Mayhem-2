extends Condition


func run(_actor : Character, controller : AIController) -> int:
#	if TargetTracker.get_target_count(actor) > 1:
#		controller.flee_target = TargetTracker.get_targetter(actor)
#		controller.nav_agent.set_target_position(controller.flee_target.global_position)
#		return SUCCESS
#	else:
#		controller.flee_target = null
#		return FAILURE
	
	if controller.opponents_in_sight.size() > 3:
		controller.flee_target = controller.opponents_in_sight[0]
		return SUCCESS
	else:
		# How performant is this??
		controller.flee_target = null
		return FAILURE
