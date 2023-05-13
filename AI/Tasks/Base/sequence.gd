@icon("res://AI/Tasks/Base/SequenceIcon.png")
class_name Sequence
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
		elif result == FAILURE:
#			running_child = -1
			return result
	
#	print(str(self) + "succeeded")
#	running_child = -1
	return SUCCESS
