extends RigidBody3D

@onready var timer : Timer = $DeathTimer

func _on_body_entered(body):
	if body is Character:
		if body is Produce:
			pass
		else:
			body.set_is_slipping(true)
			queue_free()
		timer.start()
		$SlipSound.play()
	if body is StaticBody3D:
		axis_lock_linear_x = false
		axis_lock_linear_z = false


func _on_death_timer_timeout():
	queue_free()
