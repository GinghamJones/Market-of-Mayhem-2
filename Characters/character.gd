class_name Character
extends CharacterBody3D

@export var character_stats : CharacterData
@export var projectile : PackedScene
@onready var projectile_placement : Node3D = $Human_Template_Male/ProjectilePlacement

@onready var anims : AnimationTree = $AnimationTree
@onready var anim_player : AnimationPlayer = $Human_Template_Male/AnimationPlayer
@onready var right_hook : Area3D = $Human_Template_Male/metarig/Skeleton3D/RightHookBone/RightHook
@onready var left_hook : Area3D = $Human_Template_Male/metarig/Skeleton3D/LeftHookBone/LeftHook

@onready var projectile_timer : Timer = $Timers/ProjectileTimer
@onready var special_timer : Timer = $Timers/SpecialMeleeTimer
@onready var jump_timer : Timer = $Timers/JumpTimer
@onready var dodge_timer : Timer = $Timers/DodgeTimer
@onready var dodge_cooldown : Timer = $Timers/DodgeCooldown

var mouse_delta : Vector2
var is_paused : bool = false
var is_dodging : bool = false
var is_moving : bool = false : set = set_is_moving
var is_firing : bool = false : set = set_is_firing
var blocking : bool = false
var hit_detected : bool = false
var i_been_walloped : bool = false
var hit_direction : Vector3 = Vector3.ZERO
var spawn_point : Vector3 = Vector3.ZERO
var is_dead : bool = false
	
#var is_jumping : bool = false : set = set_is_jumping
var jump_force : float = 30
var punch_force : float = 15
var dodge_direction : Vector3 = Vector3.ZERO

var player_controlled : bool 
var controller : Node3D


func _ready() -> void:
	update_health()

func _process(delta: float) -> void:
	if not controller:
		return
	rotation.y = lerp_angle(rotation.y, controller.get_y_rotation(), 0.2)


func _physics_process(delta: float) -> void:
	if is_firing:
		_handle_firing()
		if character_stats.single_fire:
			is_firing = false
			
	move_my_ass(delta)


#### Movement functions ####

func move_my_ass(delta):
	if not controller:
		return
	var direction : Vector3 = controller.get_direction()
	
	if not is_on_floor():# and not is_jumping:
		direction.y -= character_stats.gravity 
#	elif is_jumping and is_on_floor():
#		target_velocity.y += jump_force
#		if $JumpTimer.is_stopped():
#			set_is_jumping(false)
	else:
		direction.y = 0
	
	if i_been_walloped:
		# Hit direction comes from the take_damage functiion
		velocity = hit_direction * punch_force
		hit_direction = Vector3.ZERO
		i_been_walloped = false
	else:
		velocity = lerp(velocity, direction * character_stats.move_speed, character_stats.acceleration)
		if is_dodging:
			velocity = dodge_direction * 30
		handle_movement_anims(delta)

	move_and_slide()


func handle_movement_anims(delta : float):
	if velocity.length() > 2.0:
		set_is_moving(true)
		var anim_speed : float = velocity.length() * delta + 2.0
		anims.set("parameters/TimeScale/scale", anim_speed)
	else:
		set_is_moving(false)
		anims["parameters/Movement/playback"].travel("Character_Idle")
		anims.set("parameters/TimeScale/scale", 1.1)


#### Action functions ####

func start_dodge(new_direction : Vector3):
	if dodge_cooldown.is_stopped():
		dodge_timer.start()
		dodge_direction = new_direction
		is_dodging = true

func stop_dodge():
	dodge_cooldown.start()
	is_dodging = false
		
func jump():
	set_oneshot("parameters/JumpShot/request")

func punch():
	if set_oneshot("parameters/PunchShot/request"):
		hit_detected = false
		right_hook.monitoring = true
		left_hook.monitoring = true

func block():
	if set_oneshot("parameters/BlockShot/request"):
		blocking = true
		
func _handle_firing():
	# Overridden if projectile is particle based
	if projectile_timer.is_stopped(): #and character_stats.current_ammo > 0:
		projectile_timer.start()
		spawn_projectile()
		character_stats.current_ammo -= 1
	
func use_super_move():
	pass


func spawn_projectile():
	var p : Projectile = projectile.instantiate()
	get_tree().root.add_child(p)
	p.global_transform = $Human_Template_Male/ProjectilePlacement.global_transform
	p.initiate(character_stats.projectile_speed, character_stats.projectile_damage, self)
	p.fire(velocity)

#### Damage related functions ####

func take_damage(damage : int, direction : Vector3):
	if blocking:
		character_stats.current_health -= damage - 5
	else:
		character_stats.current_health -= damage
		i_been_walloped = true
		hit_direction = direction
		update_health()
	
	if character_stats.current_health <= 0:
		die()


func take_projectile_damage(damage : int, status_effect):
	character_stats.current_health -= damage
	
	update_health()
	if character_stats.current_health <= 0:
		die()


func begin_slow_effect():
	$Timers/SlowTimer.start()
	character_stats.move_speed -= 5

func end_slow_effect():
	character_stats.move_speed += 5


func die():
	set_physics_process(false)
	set_process(false)
	$CollisionShape3D.call_deferred("set_disabled", true)
	$Human_Template_Male/metarig/Skeleton3D.physical_bones_start_simulation()
	$Human_Template_Male/metarig/Skeleton3D.animate_physical_bones = false
	$Timers/RespawnTimer.start()
	is_dead = true


#### Setter functions ####

func set_oneshot(anim : String) -> bool:
	# This checks if a oneshot is already playing and returns false if so. A false return stops the requested action from taking place.
	var oneshot_anims : Array = [anims["parameters/BlockShot/active"], anims["parameters/JumpShot/active"], anims["parameters/PunchShot/active"]]
	for oneshot in oneshot_anims:
		if oneshot == true:
			return false
	
	anims.set(anim, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	return true


func set_is_moving(value : bool):
	# A function to make sure movement anims are set only when move state changes, not every frame
	if is_moving != value:
		is_moving = value
	if is_moving:
		anims["parameters/Movement/playback"].travel("Character_Walk")
	else:
		anims["parameters/Movement/playback"].travel("Character_Idle")
		anims.set("parameters/TimeScale/scale", 1.1)


func set_is_firing(value): 
	is_firing = value


#### Signal functions ####

func _on_left_hook_body_entered(body):
	if body == self:
		return
	if body.has_method("take_damage") and not hit_detected:
		body.take_damage(character_stats.base_damage, -transform.basis.z.normalized())
		$Human_Template_Male/metarig/Skeleton3D/RightHookBone/ParticleSpawner.spawn_particle()
		hit_detected = true
		left_hook.set_deferred("monitoring", false)


func _on_right_hook_body_entered(body):
	if body == self:
		return
	if body.has_method("take_damage") and not hit_detected:
		body.take_damage(character_stats.base_damage, -transform.basis.z.normalized())
		$Human_Template_Male/metarig/Skeleton3D/RightHookBone/ParticleSpawner.spawn_particle()
		hit_detected = true
		right_hook.set_deferred("monitoring", false)
		


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "Character_Attack":
		left_hook.set_deferred("monitoring", false)
		right_hook.set_deferred("monitoring", false)
	elif anim_name == "Character_Block":
		blocking = false


#### Misc functions ####

func initiate():
	for node in get_children():
		if node.is_in_group("Controller"):
			controller = node
			$ControllerPositioner.remote_path = node.get_path()
			break
	
	if player_controlled:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	controller.actor = self
	controller.initiate()
		
	$Human_Template_Male.rotation_degrees.y = 180.0
	
	right_hook.monitoring = false
	left_hook.monitoring = false
	
	character_stats.current_health = character_stats.max_health
	character_stats.current_ammo = character_stats.max_ammo
	global_position = spawn_point
	
	$Label3D.text = str(get_class()) + ": health = " + str(character_stats.current_health)


func update_health():
	$Label3D.text = str(character_stats.Team) + ": health = " + str(character_stats.current_health)


func respawn():
	global_position = spawn_point
	set_physics_process(true)
	set_process(true)
	$CollisionShape3D.call_deferred("set_disabled", false)
	character_stats.current_ammo = character_stats.max_ammo
	character_stats.current_health = character_stats.max_health
	is_dead = false
	$Human_Template_Male/metarig/Skeleton3D.physical_bones_stop_simulation()
	$Human_Template_Male/metarig/Skeleton3D.animate_physical_bones = true
	$Human_Template_Male/metarig/Skeleton3D.reset_bone_poses()
	update_health()
