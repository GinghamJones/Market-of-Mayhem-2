extends Condition


func run(actor : Character, controller):
	if controller.target:
		return true
	
	return false
