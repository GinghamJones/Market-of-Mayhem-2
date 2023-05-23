extends Node


func run(controller : AIController):
	# Do nothing if no target
	var current_target : Character = controller.target
	if current_target == null:
		return
	
#	if controller.is_target_in_special_range():
#		if controller.is_special_available():
#			controller.use_special()
#			return
	
	if controller.is_target_in_punch_range():
		if not controller.is_target_aimed_at():
			return
		if controller.is_punch_available():
			controller.punch()
			return
	
	if controller.is_target_aimed_at():
		if controller.is_projectile_available():
			controller.fire()
			return
	
