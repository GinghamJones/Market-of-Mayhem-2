extends Node3D

@onready var particle : GPUParticles3D = $Frosting
@onready var timer : Timer = $FrostingTimer
@onready var raycast : RayCast3D = $FrostingHitDetect

var firing : bool = false

func _physics_process(delta):
	if firing:
		var part_material : ParticleProcessMaterial = particle.process_material
		part_material.set("initial_velocity_max", timer.time_left * 3)
		raycast.target_position = Vector3(0, 0, -timer.time_left)
		particle.rotation.z = randf_range(-PI, PI)
		
	else:
		pass


func fire():
	firing = true
	raycast.enabled = true
	timer.start()
#	particle.emitting = true
	particle.restart()


func cease_fire():
	firing = false
	raycast.enabled = false
	particle.emitting = false
	particle.rotation.z = 0


