extends Condition

var think_time : float = randf_range(0.05, 0.2)
var time_elapsed : float = 0

func run(actor : Character, controller : Controller) -> bool:
#	time_elapsed += get_physics_process_delta_time()
#	if time_elapsed >= think_time:
#		think_time = randf_range(0.05, 0.2)
#		time_elapsed = 0
#		return true
#	else:
#		return false
	return true
