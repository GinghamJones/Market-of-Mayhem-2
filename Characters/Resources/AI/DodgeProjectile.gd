extends Action


func run(actor : Character, controller : Controller) -> bool:
	controller.dodge(actor.global_transform.basis.x)
	return true
