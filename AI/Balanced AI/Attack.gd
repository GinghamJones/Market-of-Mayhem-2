extends Node


func run(controller : AIController):
	# Do nothing if no target
	if controller.target == null:
		return
	
#	if controller.is_target_in_special_range():
#		if controller.is_special_available():
#			controller.use_special()
#			return
	
	if controller.is_target_in_punch_range():
		if controller.is_punch_available():
			controller.punch()
			return
	
	if controller.is_target_aimed_at():
		if controller.is_projectile_available():
			controller.fire()
			return

