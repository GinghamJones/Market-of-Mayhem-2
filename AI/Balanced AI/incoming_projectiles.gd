extends Node


func run(controller : AIController):
	var check : bool = controller.detection_area.is_projectile_comin_for_me()
	if check:
		var direction : Vector3 = choose_dodge_direction()
		controller.dodge(direction)
	
	return


func choose_dodge_direction() -> Vector3:
	var rand_int : int = randi() % 2
	if rand_int == 0:
		return Vector3.RIGHT
	else:
		return Vector3.LEFT

