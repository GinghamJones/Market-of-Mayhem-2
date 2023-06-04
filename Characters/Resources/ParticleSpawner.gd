extends RayCast3D

@onready var particle : PackedScene = preload("res://Characters/Assets/punch_particle.tscn")


func spawn_particle():
	if is_colliding():
		var spawn_point = get_collision_point()
		var p : GPUParticles3D = particle.instantiate()
		get_tree().root.add_child(p)
		p.global_position = spawn_point
		p.emitting = true
	
