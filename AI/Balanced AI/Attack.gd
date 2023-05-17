extends Node


func run(controller : AIController):
	# Do nothing if no target
	if controller.target == null:
		return
	
	var detection_cast : Area3D = controller.detection_area
	
#	if controller.is_target_in_special_range():
#		if controller.is_special_available():
#			controller.use_special()
#			return
	
	if controller.is_target_in_punch_range():
		controller.punch()
		return
	
	if controller.is_target_aimed_at():
		if controller.is_projectile_available():
			controller.fire()
			return

