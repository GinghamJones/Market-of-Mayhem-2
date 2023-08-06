extends Projectile

@onready var vase_part = preload("res://Projectile/Vase/vase_shatter.tscn")

func _on_body_entered(body):
	if body is Character:
		if body.get_team() == who_fired_me.get_team():
			pass
		else:
			$ImpactSound.play()
			set_is_active(false)
			spawn_smoke(body)
			spawn_particles()
	else:
		$ImpactSound.play()
		spawn_smoke(body)
		set_is_active(false)
		spawn_particles()
		
	
func spawn_particles() -> void:
	var v = vase_part.instantiate()
	get_tree().root.add_child(v)
	v.global_position = global_position
	$Flower.hide()
	$GPUParticles3D.emitting = false
	$GPUParticles3D2.emitting = false
	await $ImpactSound.finished
	queue_free()
