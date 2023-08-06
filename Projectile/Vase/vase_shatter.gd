extends GPUParticles3D

@onready var raycast : RayCast3D = $RayCast3D

func _ready() -> void:
	emitting = true
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.is_in_group("Floor"):
			$GPUParticlesCollisionBox3D.global_position.y = collider.global_position.y + 0.1


func _physics_process(_delta: float) -> void:
	if emitting == false:
		queue_free()
