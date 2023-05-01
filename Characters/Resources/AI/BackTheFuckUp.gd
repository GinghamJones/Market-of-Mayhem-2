extends Action
var timer : Timer = null


func run(actor : Character, controller : AIController) -> int:
	if timer == null:
		timer = Timer.new()
		add_child(timer)
		timer.wait_time = 0.5
		timer.one_shot = true
		timer.start()
	
	if timer.is_stopped():
		timer.queue_free()
		timer = null
		return SUCCESS
	else:
		controller.back_up()
		return RUNNING



