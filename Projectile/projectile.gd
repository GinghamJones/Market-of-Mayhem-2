class_name Projectile
extends RigidBody3D

@onready var lifespan_timer : Timer = $LifespanTimer
@onready var smoke_cloud = preload("res://ParticleFX/smoke_cloud.tscn")

var damage : int = 0
@export var status_effect : String = ""

var is_active : bool = true : set = set_is_active
var who_fired_me : Character = null
#var previous_velocity : Vector3 = Vector3.ZERO


func fire(speed : float):
#	print(global_rotation)
	apply_central_impulse(-transform.basis.z * speed)
	$GPUParticles3D.emitting = true
	$GPUParticles3D2.emitting = true


func initiate(new_damage : int, requester : Character):
	damage = new_damage
	who_fired_me = requester


#func _physics_process(delta):
#	if is_active:
#		previous_velocity = linear_velocity
##		print(previous_velocity.length())


func _on_body_entered(body):
	if body is Character:
		if body.get_team() == who_fired_me.get_team():
			pass
		else:
			$ImpactSound.play()
			body.take_projectile_damage(damage, who_fired_me, status_effect)
			spawn_smoke(body)
			set_is_active(false)
	else:
		$ImpactSound.play()
		spawn_smoke(body)
		set_is_active(false)
		

func set_is_active(value : bool) -> void:
	is_active = value
	if value == false:
		set_deferred("contact_monitor", false)
		$GPUParticles3D.emitting = false
		$GPUParticles3D2.emitting = false
		lock_rotation = false


func spawn_smoke(collider) -> void:
		var s : GPUParticles3D = smoke_cloud.instantiate()
		get_tree().root.add_child(s)
		s.global_position = global_position
		

func _on_lifespan_timer_timeout():
	queue_free()

