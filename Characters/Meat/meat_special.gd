extends Area3D

var master : Character = null

func _on_body_entered(body: Node3D) -> void:
	if body is Character:
		if body is MeatDude:
			return
		body.take_damage(master.character_stats.special_damage, Vector3(0, 0, -1), master)
		queue_free()
