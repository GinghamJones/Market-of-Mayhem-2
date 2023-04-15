extends Condition


func run(actor : Character, controller):
	if controller.target:
		controller.nav_agent.set_target_position(controller.target.global_position)
		return true
	
	return false
