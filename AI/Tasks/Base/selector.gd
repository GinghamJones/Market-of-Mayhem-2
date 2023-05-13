@icon("res://AI/Tasks/Base/SelectorIcon.png")
class_name Selector
extends BehaviorTree


func _ready():
	children = get_children()


func run(actor, controller : AIController) -> int:
	if running_child != NOT_RUNNING:
		var result : int = children[running_child].run(actor, controller)
		if result != RUNNING:
			running_child = NOT_RUNNING
		return result
		
	for i in children.size():
#		print(str(i) + " " + str(children[i]))
		var result : int = children[i].run(actor, controller)
		
		if result == RUNNING:
			running_child = i
			return result
		elif result == SUCCESS:
#			running_child = -1
			return result

#	print(str(self) + "failed")
#	running_child = -1
	return FAILURE
