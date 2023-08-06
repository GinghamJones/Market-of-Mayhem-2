extends GPUParticles3D


func _ready() -> void:
	emitting = true

func _physics_process(delta: float) -> void:
	if not emitting:
		queue_free()
