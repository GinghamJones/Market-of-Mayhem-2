extends Node3D

@onready var particle : GPUParticles3D = $Frosting
@onready var timer : Timer = $FrostingTimer
@onready var raycast : RayCast3D = $FrostingHitDetect
@onready var hit_timer : Timer = $HitDelayTimer

var firing : bool = false
var num_times_hit : int = 0

signal coat_with_frosting


func _ready():
	coat_with_frosting.connect(Callable(get_parent(), "slather_em"))


func _physics_process(delta):
	if firing:
		var part_material : ParticleProcessMaterial = particle.process_material
		part_material.set("initial_velocity_max", timer.time_left * 3)
		raycast.target_position = Vector3(0, 0, -timer.time_left * 3)
		particle.rotation.z = randf_range(-PI, PI)
		if hit_timer.is_stopped():
			check_raycast()
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
	raycast.target_position = Vector3.ZERO


func check_raycast():
	if raycast.is_colliding():
		var who_dis = raycast.get_collider()
		if who_dis is Character and not who_dis is Baker:
			emit_signal("coat_with_frosting", who_dis)
			hit_timer.start()
