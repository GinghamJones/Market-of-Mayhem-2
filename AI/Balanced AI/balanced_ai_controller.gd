class_name BalancedAIController
extends AIController


func initiate(new_actor):
	super(new_actor)
	var new_module = balanced_module.instantiate()
	add_child(new_module)
	ai_module_children = new_module.get_children()
	cur_ai_tree = new_module
