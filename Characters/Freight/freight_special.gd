extends Area3D

var master : Character = null
var force : float = 10

func _on_body_entered(body: Node3D) -> void:
	if body is Character:
		if body is MeatDude:
			return
		body.take_damage(master.character_stats.special_damage, Vector3(0, 0, -1), master)
		body.apply_impulse(-master.transform.basis.z, force, 1.0)
		queue_free()
