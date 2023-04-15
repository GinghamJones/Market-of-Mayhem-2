@icon("res://Characters/Resources/AI/Tasks/Base/SelectorIcon.png")
class_name Selector
extends BehaviorTree

var children : Array


func _ready():
	children = get_children()


func run(actor : Character, controller) -> bool:
	for child in children:
		if child.run(actor, controller):
			return true
	
	return false
