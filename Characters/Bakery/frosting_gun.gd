extends Node3D

@onready var particle : GPUParticles3D = $Frosting
@onready var timer : Timer = $FrostingTimer
@onready var raycast : RayCast3D = $FrostingHitDetect
@onready var hit_timer : Timer = $HitDelayTimer
@onready var actor : Baker = get_parent()

var firing : bool = false
var num_times_hit : int = 0
var time_raycast : float = 0 
var min_velocity : float = 21.0


const STARTUP_RAY_LENGTH_MULTIPLIER = 5
const WINDDOWN_RAY_LENGTH_MULTIPLIER = 3
const PARTICLE_VELOCITY_MULTIPLIER = 3
const STARTUP_TIME = 0.5

signal slather_em


func _ready():
	slather_em.connect(Callable(get_parent(), "slather_em"))


func _physics_process(delta : float):
	if firing:
		handle_particle_effect()
		handle_raycast(delta)
	else:
		pass


func handle_particle_effect() -> void:
	var part_material : ParticleProcessMaterial = particle.process_material
	var parent_velocity_length : float = actor.velocity.length()
	var directional_velocity : float = parent_velocity_length * -actor.move_direction.z

	part_material.set("initial_velocity_min", min_velocity + directional_velocity)
	part_material.set("initial_velocity_max", timer.time_left * PARTICLE_VELOCITY_MULTIPLIER + directional_velocity)


func handle_raycast(delta : float) -> void:
	time_raycast += delta
	
	if time_raycast < STARTUP_TIME:
		raycast.target_position = Vector3(0, 0, -time_raycast * STARTUP_RAY_LENGTH_MULTIPLIER)
	else:
		raycast.target_position = Vector3(0, 0, -timer.time_left * WINDDOWN_RAY_LENGTH_MULTIPLIER)
	#particle.rotation.z = randf_range(-PI, PI)
	if hit_timer.is_stopped():
		hit_timer.start()
		check_raycast()


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
	time_raycast = 0


func check_raycast():
	if raycast.is_colliding():
		var who_dis = raycast.get_collider()
		if who_dis is Baker:
			return
		if who_dis is Character:
			emit_signal("slather_em", who_dis)
#			hit_timer.start()
