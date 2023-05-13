extends Condition

var dodge_timer : float = randf_range(0.05, 0.2)
var time_elapsed : float = 0

func run(_actor : Character, _controller : AIController) -> int:
	time_elapsed += get_physics_process_delta_time()
	if time_elapsed >= dodge_timer:
		dodge_timer = randf_range(0.05, 0.2)
		time_elapsed = 0
		return SUCCESS
	else:
		return FAILURE
