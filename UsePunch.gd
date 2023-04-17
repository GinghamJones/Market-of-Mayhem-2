extends Action

func run(actor : Character, controller) -> bool:
#	controller.face_enemy()
	actor.punch()
	return true
