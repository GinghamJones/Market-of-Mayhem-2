extends Node

@onready var master = get_parent()

func run(controller : AIController):
	# Do nothing if no target
	var current_target : Character = controller.target
	if current_target == null:
		return
	
#	if controller.is_special_available():
#		if controller.is_target_in_special_range():
#			if not controller.is_target_aimed_at():
#				return
#			else:
#				controller.use_special()

	if controller.is_punch_available():
		if controller.is_target_in_punch_range():
			if not controller.is_target_aimed_at():
				return
			else:
				controller.punch()
				master.just_punched = true
				return

	if controller.is_projectile_available():
		if controller.is_target_aimed_at():
			controller.fire()
			return
