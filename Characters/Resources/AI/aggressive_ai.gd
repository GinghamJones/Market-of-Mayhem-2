extends Node

var actor : Character = null
@onready var child = get_child(0)
var controller : Controller


func _ready():
	randomize()


func tick():
	if actor:
		child.run(actor, controller)
