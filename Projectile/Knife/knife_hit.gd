extends GPUParticles3D

func _physics_process(delta: float) -> void:
	if not emitting:
		queue_free()
