extends Action


func run(actor : Character, controller) -> bool:
#	controller.face_enemy()
	actor._handle_firing()
	return true
