extends GPUParticles3D

func _physics_process(delta):
	if not emitting:
		queue_free()
