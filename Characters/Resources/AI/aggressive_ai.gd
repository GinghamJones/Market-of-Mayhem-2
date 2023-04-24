extends Node

var actor : Character = null
@onready var child = get_child(0)
var controller : AIController


func _ready():
	randomize()


func tick():
	if actor:
		child.run(actor, controller)
