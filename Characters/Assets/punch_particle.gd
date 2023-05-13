extends GPUParticles3D

func _physics_process(_delta):
	if not emitting:
		queue_free()
