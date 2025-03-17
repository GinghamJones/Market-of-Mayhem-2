class_name AttackComponent
extends Node3D

enum Punch_States{
	CANT_PUNCH,
	PUNCHED_LEFT,
	PUNCHED_RIGHT,
}

#@onready var right_hook = $RightHook
@onready var left_hook = $LeftHook
@onready var projectile_placement: Marker3D = $ProjectilePlacement
@onready var punch_anims: AnimationPlayer = $PunchAnims
@onready var projectile_timer: Timer = $ProjectileTimer
@onready var special_melee_timer: Timer = $SpecialMeleeTimer
@onready var punch_timer: Timer = $PunchTimer
@onready var punch_particle : PackedScene = preload("res://Characters/Assets/punch_particle.tscn")
@onready var punch_sound: AudioStreamPlayer3D = $PunchSound
@onready var actor : Character = get_parent()

#@export var actor : Character
@export_category("Punch Stuff")
@export var punch_dam : int = 10
@export var punch_speed : float = 1.0
@export var punch_force : float = 10.0
@export_category("Shooty Stuff")
@export var projectile : PackedScene
@export var projectile_speed : float = 5.0
@export var projectile_fire_delay : float = 1.0
@export var max_ammo : int = 10

var can_punch : bool = true
var just_punched : bool = false
var can_fire : bool = true
var hit_detected : bool = false
var current_ammo : int = 0

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	projectile_timer.wait_time = projectile_fire_delay
	current_ammo = max_ammo
	randomize()


func punch() -> int:
	if not can_punch:
		return Punch_States.CANT_PUNCH
	
	# Set the physics to monitor
	left_hook.call_deferred("set_contact_monitor", true)
	left_hook.max_contacts_reported = 1
	
	punch_anims.play("Punch_Left", -1, punch_speed)
	
	# Currently this is borked by if you don't do a 1-2, your next punch may take forever to recover from
	# Punches alternate and don't reset to left punch if wait a long time to punch after one punch
	if not just_punched:
		just_punched = true
		punch_timer.start()
		return Punch_States.PUNCHED_RIGHT
	else:
		just_punched = false
		var random_num = rng.randf_range(0.6, 1.1)
		punch_timer.wait_time = random_num
		punch_timer.start()
		can_punch = false
		return Punch_States.PUNCHED_LEFT


func spawn_punch_particle(left_hand : bool) -> void:
		punch_sound.play()
		var p = punch_particle.instantiate()
		add_child(p)
		p.set("transform/top_level", true)
		p.global_position = left_hook.global_position


func fire():
	if not can_fire or current_ammo == 0:
		return 

	# Need to set global transform, actor, top_level (unless we make a 'projectile_holder')
	#!!! Try adding global projectile_holder that counts projectiles and deletes if above threshold !!!#
	var p = projectile.instantiate()
	if p is not FrostingGun and p is not Lazer:
		p.top_level = true
	projectile_placement.add_child(p)
	p.actor = actor
	p.global_transform = projectile_placement.global_transform
	p.fire(determine_projectile_speed())
	can_fire = false
	current_ammo -= 1
	projectile_timer.start()


func determine_projectile_speed() -> float:
	var projectile_speed = projectile_speed
	const FORWARD_SPEED = 1.25
	const BACKWARD_SPEED = 0.6
	
	# Increase speed if moving forward, decrease if backward
	if actor.move_direction > 0:
		projectile_speed *= BACKWARD_SPEED
	elif actor.move_direction < 0:
		projectile_speed *= FORWARD_SPEED
	else:
		projectile_speed *= 1
	
	return projectile_speed


func _on_punch_timer_timeout() -> void:
	can_punch = true
	punch_timer.wait_time = 0.5


func _on_projectile_timer_timeout() -> void:
	can_fire = true


func _on_punch_anims_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Punch_Left":
		left_hook.call_deferred("set_contact_monitor", false)
		hit_detected = false


func _on_left_hook_body_entered(body: Node3D) -> void:
	if body.is_in_group("Level"):
		spawn_punch_particle(false)
	elif body is HealthComponent:
		if hit_detected or body.actor == self or body.actor.get_team() == actor.get_team():
			return
		body.take_damage(punch_dam, self)
		body.apply_impulse(-transform.basis.z, punch_force, 0.1)
		spawn_punch_particle(false)

	left_hook.call_deferred("set_contact_monitor", false)
	hit_detected = true


func reset():
	current_ammo = max_ammo
