extends Action


func run(actor : Character, controller : AIController) -> int:
	controller.dodge(actor.global_transform.basis.x)
	return SUCCESS
