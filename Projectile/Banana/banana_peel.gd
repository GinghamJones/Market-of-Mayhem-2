extends RigidBody3D

@onready var timer : Timer = $DeathTimer


func _on_body_entered(body):
	if body is Character:
		print("yo ass slipped")
		timer.start()
	if body is StaticBody3D:
		axis_lock_linear_x = false
		axis_lock_linear_z = false


func _on_death_timer_timeout():
	queue_free()