extends Node

@onready var master = get_parent()
@onready var controller : AIController = master.controller

func run():
	# Do nothing if no target
	var current_target : Character = controller.target
	if current_target == null or not $PunchThinkTimer.is_stopped() or not $JustPunchedTimer.is_stopped() or not $FireThinkTimer.is_stopped():
		return
	
#	if controller.is_special_available():
#		if controller.is_target_in_special_range():
#			if not controller.is_target_aimed_at():
#				return
#			else:
#				controller.use_special()

	if controller.is_punch_available():
		if controller.is_target_in_punch_range():
			if not $JustPunchedTimer.is_stopped():
				return
			if $PunchThinkTimer.is_stopped():
				$PunchThinkTimer.wait_time = randf_range(0.1, 0.3)
				$PunchThinkTimer.start()
#				controller.current_timer = $Timer
			

	if controller.is_projectile_available():
		if controller.is_target_aimed_at():
			if $FireThinkTimer.is_stopped():
				$FireThinkTimer.wait_time = randf_range(0.1, 0.2)
				$FireThinkTimer.start()
#				controller.current_timer = $FireThinkTimer
			return


func punch() -> void:
	controller.punch()
	master.just_punched = true
	$JustPunchedTimer.start()
#	controller.current_timer = $JustPunchedTimer

func fire() -> void:
	controller.fire()
