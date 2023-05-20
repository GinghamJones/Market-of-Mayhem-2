extends AIController

@onready var manager_ai_module : PackedScene = preload("res://NPC/Manager/Manager AI/manager_ai_module.tscn")

func initiate(new_actor):
	super(new_actor)
	var new_module = manager_ai_module.instantiate()
	add_child(new_module)
	ai_module_children = new_module.get_children()
	cur_ai_tree = new_module


func grab_target():
	actor.fuck_em_up(target)
	target = null


func is_target_in_grab_distance() -> bool:
	if (target.global_position - actor.global_position).length() <= 1.0:
		return true
	else:
		return false
