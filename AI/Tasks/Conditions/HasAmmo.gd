extends Condition

func run(actor : Character, controller) -> bool:
	if actor.character_stats.current_ammo > 0:
		return true
	return false
