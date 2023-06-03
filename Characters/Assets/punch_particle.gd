extends GPUParticles3D

func _ready() -> void:
	emitting = true
	$PunchSparks.emitting = true

func _physics_process(_delta):
	if not emitting and not $PunchSparks.emitting:
		queue_free()
