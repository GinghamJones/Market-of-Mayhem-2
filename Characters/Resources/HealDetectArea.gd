extends Area3D

@onready var master : Character = get_parent()

func _on_body_entered(body: Node3D) -> void:
	if body == master:
		pass
	else:
		master.is_healing = false


func _on_body_exited(_body: Node3D) -> void:
	if get_overlapping_bodies().size() > 1:
		pass
	else:
		master.is_healing = true


func disable() -> void:
#	set_process(false)
#	set_physics_process(false)
	set_block_signals(true)
	monitoring = false
	


func enable() -> void:
#	set_process(true)
	set_block_signals(false)
	monitoring = true
	
