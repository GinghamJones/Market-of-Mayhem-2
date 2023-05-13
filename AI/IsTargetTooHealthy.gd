extends Condition

func run(actor, controller : AIController) -> int:
	if controller.target.character_stats.current_health - actor.character_stats.current_health > 50:
		return FAILURE
	else:
		return SUCCESS
