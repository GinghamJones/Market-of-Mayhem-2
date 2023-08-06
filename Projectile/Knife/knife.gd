extends Projectile

@onready var raycast : RayCast3D = $RayCast3D
@onready var hit_particle = preload("res://Projectile/Knife/knife_hit.tscn")

func _physics_process(delta: float) -> void:
	if raycast.is_colliding() and not is_active:
		var collision_point : Vector3 = raycast.get_collision_point()
		var k : GPUParticles3D = hit_particle.instantiate()
		add_child(k)
		k.emitting = true
		global_position = collision_point
		freeze = true
