extends AIController

@onready var manager_ai_module : PackedScene = preload("res://NPC/Manager/Manager AI/manager_ai_module.tscn")

func initiate(new_actor):
	super(new_actor)
	var new_module = manager_ai_module.instantiate()
	add_child(new_module)
	cur_ai = new_module


func run(delta : float):
	if actor:
		cur_ai.run(self)
		var new_direction : Vector3 = get_direction()
		emit_signal("direction_computed", delta, new_direction)


func grab_target():
	actor.fuck_em_up(target)


func is_target_in_grab_distance() -> bool:
	if detection_area.am_i_facing_target(target.global_position):
		if (target.global_position - actor.global_position).length() <= 1.0:
			return true
		else:
			return false
	
	return false
