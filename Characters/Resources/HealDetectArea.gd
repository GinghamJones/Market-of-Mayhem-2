extends Area3D

@onready var master : Character = get_parent()

func _on_body_entered(body: Node3D) -> void:
	if body == master:
		pass
	else:
		master.is_healing = false


func _on_body_exited(body: Node3D) -> void:
	if get_overlapping_bodies().size() > 1:
		pass
	else:
		master.is_healing = true
