@icon("res://Characters/Resources/AI/Tasks/Base/SequenceIcon.png")
class_name Sequence
extends BehaviorTree

var children : Array

func _ready():
	children = get_children()
	

func run(actor : Character, controller) -> bool:
	for child in children:
		var result = child.run(actor, controller)
		if not result:
			return false

	return true
