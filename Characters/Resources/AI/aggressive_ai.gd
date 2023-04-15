extends Node

var actor : Character = null
var controller

func tick():
	if actor:
		get_child(0).run(actor, controller)
