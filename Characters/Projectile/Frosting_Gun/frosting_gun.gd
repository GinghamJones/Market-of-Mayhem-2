class_name FrostingGun 
extends Node3D

@onready var particle : GPUParticles3D = $Frosting
@onready var timer : Timer = $LifespanTimer
@onready var raycast : RayCast3D = $FrostingHitDetect
@onready var hit_timer : Timer = $HitDelayTimer
# I dunno if this is best but it is now
#@onready var attack_component : AttackComponent = get_parent().get_parent()
@onready var death_timer: Timer = $DeathTimer

@export var damage : int = 10

var actor : Character
var firing : bool = false
var num_times_hit : int = 0
var time_raycast : float = 0 
var min_velocity : float = 15.0


const STARTUP_RAY_LENGTH_MULTIPLIER = 7
const WINDDOWN_RAY_LENGTH_MULTIPLIER = 6
const PARTICLE_VELOCITY_MULTIPLIER = 7
const STARTUP_TIME = 0.5

#signal slather_em
#signal firing_changed

func _ready():
	particle.process_material.set("initial_velocity_min", min_velocity)
	#slather_em.connect(Callable(actor, "slather_em"))
	#firing_changed.connect(Callable(actor, "set_currently_firing"))


func _physics_process(delta : float):
	if firing:
		handle_particle_effect()
		handle_raycast(delta)
	else:
		pass


func handle_particle_effect() -> void:
	#var part_material : ParticleProcessMaterial = particle.process_material
	#var parent_velocity_length : float = actor.velocity.length()
	#var directional_velocity : float = parent_velocity_length * actor.move_direction
	
	var velocity_multiplier : float = determine_projectile_speed()
	
	#part_material.set("initial_velocity_min", min_velocity)
	particle.process_material.set("initial_velocity_max", timer.time_left * PARTICLE_VELOCITY_MULTIPLIER * velocity_multiplier)
	#part_material.set("initial_velocity_max", timer.time_left * PARTICLE_VELOCITY_MULTIPLIER)


func handle_raycast(delta : float) -> void:
	time_raycast += delta
	
	if time_raycast < STARTUP_TIME:
		raycast.target_position = Vector3(0, 0, -time_raycast * STARTUP_RAY_LENGTH_MULTIPLIER)
	else:
		raycast.target_position = Vector3(0, 0, -timer.time_left * WINDDOWN_RAY_LENGTH_MULTIPLIER)
	particle.rotation.z = randf_range(-PI, PI)
	if hit_timer.is_stopped():
		hit_timer.start()
		check_raycast()


func determine_projectile_speed() -> float:
#	var projectile_speed = character_stats.projectile_speed
	const FORWARD_SPEED = 1.25
	const BACKWARD_SPEED = 0.6
	
	# Increase speed if moving forward, decrease if backward
#	var projectile_speed_modifier : float = 1
	if actor.move_direction < 0:
#		projectile_speed *= BACKWARD_SPEED
		return FORWARD_SPEED
	elif actor.move_direction > 0:
#		projectile_speed *= FORWARD_SPEED
		return BACKWARD_SPEED
	else:
		return 1
	
#	return projectile_speed


func fire(speed : float):
	firing = true
	raycast.enabled = true
	timer.start()
	particle.emitting = true
	#particle.restart()
	#firing_changed.emit(true)


func _on_lifespan_timer_timeout():
	#queue_free()
	firing = false
	raycast.enabled = false
	particle.emitting = false
	death_timer.start()
	#particle.rotation.z = 0
##	raycast.target_position = Vector3.ZERO
##	time_raycast = 0
	#firing_changed.emit(false)


func check_raycast():
	if raycast.is_colliding():
		var who_dis = raycast.get_collider()
		if who_dis is Character:
			if who_dis is Baker:
				return
			else:
				#!!! Need to take care of 'magic string' !!!#
				who_dis.take_projectile_damage(damage, actor, "slow")


func _on_death_timer_timeout() -> void:
	print("deleting frosting")
	queue_free()
