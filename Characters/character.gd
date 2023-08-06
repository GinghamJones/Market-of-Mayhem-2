class_name Character
extends CharacterBody3D

## You may find:
## Name generation in "initiate"

@export var character_stats : CharacterData
@export var projectile : PackedScene
@export var special : PackedScene

@onready var anims : AnimationTree = $CharacterAnimationTree
@onready var projectile_placement = $ProjectilePlacement
@onready var special_attach : Node3D = $NPC_Meat_Female2/Meat_Female/Skeleton3D/RightHookAttachment/SpecialAttachment
@onready var projectile_aimer : RayCast3D = $ProjectileAimer
@onready var dodge_particle: GPUParticles3D = $DodgeParticle
@onready var controller_positioner: Node3D = $ControllerPositioner

@onready var projectile_timer : Timer = $Timers/ProjectileTimer
@onready var special_timer : Timer = $Timers/SpecialMeleeTimer
@onready var dodge_timer : Timer = $Timers/DodgeTimer
@onready var dodge_cooldown : Timer = $Timers/DodgeCooldown
@onready var invincibility_timer : Timer = $Timers/InvincibilityTimer
@onready var punch_timer : Timer = $Timers/PunchTimer
@onready var heal_delay_timer: Timer = $Timers/HealDelayTimer
@onready var respawn_timer: Timer = $Timers/RespawnTimer
@onready var slip_timer: Timer = $Timers/SlipTimer
@onready var impulse_timer: Timer = $Timers/ImpulseTimer

@onready var punch_sound : AudioStreamPlayer3D = $Sounds/PunchSound
@onready var punch_particle : PackedScene = preload("res://Characters/Assets/punch_particle.tscn")

@export var default_projectile_x_rotation : float = 0

var right_hook : Area3D = null
var left_hook : Area3D = null
var skeleton : Skeleton3D = null
var special_anims : AnimationPlayer = null

var is_paused : bool = false
var is_dodging : bool = false
var is_moving : bool = false : set = set_is_moving
var is_firing : bool = false : set = set_is_firing
var is_blocking : bool = false
var hit_detected : bool = false
var im_walloped : bool = false
var is_invincible : bool = false
var is_dead : bool = false
var is_smacked : bool = false
var should_respawn : bool = true
var is_slowed : bool = false
var just_punched : bool = false
var is_healing : bool = false
var is_slipping : bool = false : set = set_is_slipping
var impulse_applied : bool = false
var just_slipped : bool = false

var impulse_direction : Vector3 = Vector3.ZERO
var impulse_speed : float = 0
var move_direction : float = 0.0
var dodge_direction : Vector3 = Vector3.ZERO
var hit_direction : Vector3 = Vector3.ZERO
var mouse_delta : Vector2 = Vector2.ZERO

var current_action : String = ""
var lives_left : int = 100 : set = set_lives_left

var spawn_point : Vector3 = Vector3.ZERO
var player_controlled : bool = false
var controller = null

var score : int = 0 : 
	set(score_to_add): 
		score += score_to_add
		emit_signal("score_changed", character_stats.my_name, score)

signal score_changed
signal respawn_complete
signal i_died
signal health_changed
signal im_done_fer


func _ready() -> void:
#	set_running(false)
	is_paused = true
	randomize()
#	character_stats.current_ammo = character_stats.max_ammo


func _process(delta: float) -> void:
	if is_paused or is_dead:
		return
	
	if is_slipping:
		if just_slipped:
			velocity = -transform.basis.z * 20
			just_slipped = false
		velocity = velocity.lerp(velocity / 1.5, 0.2)
		set_is_moving(false)
		controller.global_position = controller_positioner.global_position
		move_and_slide()
		return
	
	if is_firing:
		_handle_firing()
	
	controller.run(delta)

	move_my_ass(delta, controller.get_direction())
#	print(end_time - start_time)
	if is_healing:
		if heal_delay_timer.is_stopped():
			heal_delay_timer.start()
	
	if player_controlled:
		rotation.y -= controller.get_y_rotation() * delta
		controller.rotation.y = lerp_angle(controller.rotation.y, rotation.y, delta * 15)
	else:
		rotation.y = lerp_angle(rotation.y, controller.rotation.y, delta * 15)
#		controller.rotation.y = lerp_angle(controller.rotation.y, rotation.y, delta * 15)
	



## Is this alright to put it in _process vs _physics_process, ma?
#func _physics_process(delta: float) -> void:
#
#	if is_paused or is_dead:
#		return
#
#	if is_slipping:
#		if just_slipped:
#			velocity = -transform.basis.z * 20
#			just_slipped = false
#		velocity = velocity.lerp(velocity / 1.5, 0.2)
#		set_is_moving(false)
#		controller.global_position = $ControllerPositioner.global_position
#		move_and_slide()
#		return
#
#	if is_firing:
#		_handle_firing()
#
#	controller.run(delta)
#
#	move_my_ass(delta, controller.get_direction())
##	print(end_time - start_time)
#	if is_healing:
#		if heal_delay_timer.is_stopped():
#			heal_delay_timer.start()
	

########################## Movement functions ###########################################

func move_my_ass(delta : float, direction : Vector2):
#	print(direction)
	if impulse_applied:
		var new_velocity : Vector3 = transform.basis * impulse_direction * impulse_speed
		velocity = velocity.lerp(new_velocity, 0.5)
		# Maybe??
		set_is_moving(false)
		move_and_slide()
		return
	else:
		var new_direction : Vector3 = (transform.basis * Vector3(direction.x, 0, direction.y)).normalized()

		velocity = lerp(velocity, new_direction * get_speed(), get_acceleration())

		if velocity.length() > get_speed():
			velocity = velocity.normalized() * get_speed()

		handle_movement_anims(delta)

	if not is_on_floor():
		velocity.y -= character_stats.gravity 
	else:
		velocity.y = 0

	move_and_slide()


func apply_impulse(new_direction : Vector3, new_speed : float, time : float) -> void:
	impulse_applied = true
	impulse_direction = new_direction
	impulse_speed = new_speed
	impulse_timer.wait_time = time
	impulse_timer.start()


func handle_movement_anims(delta : float):
	if velocity.length() > 2.0:
		set_is_moving(true)
		var anim_speed : float = velocity.length() * delta + 1.0
		anims.set("parameters/TimeScale/scale", anim_speed)
	else:
		set_is_moving(false)


############################## Action functions #############################################

func request_action(action : String):
	if current_action == "dead" or is_paused:
		return
	
	if action == "StopFire":
		is_firing = false
		current_action = ""
		return
	if action == "Dodge":
		if current_action == "Block" or current_action == "Punch":
			return
		
		start_dodge(controller.get_dodge_direction())
		return
			
	if current_action != "":
		return
	
	if action == "Attack":
		if just_punched:
			attack(1)
		else:
			attack(0)
	elif action == "Block":
		block()
	elif action == "Fire":
		is_firing = true
	elif action == "Special":
		use_super_move()
	else:
		print("i don't understand yer action...")
		print(action)
	
	current_action = action


func start_dodge(new_direction : Vector2):
	if dodge_cooldown.is_stopped():
		dodge_timer.start()
		dodge_particle.emitting = true
		dodge_direction = Vector3(new_direction.x, 0, new_direction.y)
		apply_impulse(dodge_direction, character_stats.dodge_force, 0.2)
#		is_dodging = true


func stop_dodge():
	dodge_cooldown.start()
#	is_dodging = false


func attack(which_punch : int):
	if which_punch == 0:
		if anims.set_oneshot("parameters/LeftAttackShot/request"):
			hit_detected = false
			left_hook.monitoring = true
			handle_just_punched()
	else:
		if anims.set_oneshot("parameters/RightAttackShot/request"):
			hit_detected = false
			right_hook.monitoring = true
			punch_timer.start()

func handle_just_punched() -> void:
	just_punched = true
#	var new_timer : SceneTreeTimer = get_tree().create_timer(0.5)
	await get_tree().create_timer(0.5).timeout
	punch_timer.start()
	just_punched = false


func block():
	if anims.set_oneshot("parameters/BlockShot/request"):
		is_blocking = true


func _handle_firing():
	# Overridden if Character is Baker or Freight
	if get_ammo() <= 0:
		pass
	else:
		if projectile_timer.is_stopped():
			projectile_timer.start()
			anims.set_oneshot("parameters/ProjectileShot/request")
#			await anims.animation_finished
			spawn_projectile()
				
			if character_stats.single_fire:
				is_firing = false
			
			character_stats.current_ammo -= 1
			if player_controlled:
				controller.update_hud(get_ammo())
			
		else:
			pass


func use_super_move():
	if anims.set_oneshot("parameters/SpecialShot/request"):
		special_timer.start()
		var s = special.instantiate()
		special_attach.add_child(s)
		await anims.animation_finished
		s.queue_free()
		
	

############################## Damage related functions ###########################################

func take_damage(damage : int, who_dunnit):
	if is_invincible:
		return
	
	play_damage_anim(damage)
	
	if is_blocking:
		character_stats.current_health -= damage - 5
	else:
		character_stats.current_health -= damage
		
		# Set im_walloped so phys_process can calculate punched velocity
#		im_walloped = true
#		hit_direction = direction
		
		update_health()
	
	if character_stats.current_health <= 0:
		if who_dunnit is Manager:
			pass
		else:
			who_dunnit.set("score", 1)
		die()


func take_projectile_damage(damage : int, who_dunnit : Character, status_effect : String = ""):
	if is_invincible:
		return
	
	play_damage_anim(damage)
	
	if status_effect != "":
		call(status_effect)
	
	character_stats.current_health -= damage
	
	update_health()
		
	if character_stats.current_health <= 0:
		who_dunnit.set("score", 1)
		die()


func play_damage_anim(force : float) -> void:
	var anim : Animation = special_anims.get_animation("Character/Hit")
	anim.track_set_key_value(0, 1, Vector4(1.0, 0.051, 0.0, force * 0.04))
	
	special_anims.play("Character/Hit")

func slow():
	if not is_slowed:
		$Timers/SlowTimer.start()
		character_stats.move_speed -= 4
		is_slowed = true

func end_slow_effect():
	character_stats.move_speed += 4


func heal() -> void:
	if character_stats.current_health < character_stats.max_health:
		character_stats.current_health += 5
		update_health()

func die():
#	emit_signal("i_died", self)
	current_action = "dead"
	lives_left -= 1
#	set_running(false)
	is_paused = true
	
	if controller is AIController:
		controller.die()
	
	call_deferred("set_collision_layer_value", 2, false)
	call_deferred("set_collision_mask_value", 2, false)
	$HealDetectArea.disable()
	
#	$CollisionShape3D.call_deferred("set_disabled", true)
	
	# Activate ragdoll
	skeleton.physical_bones_start_simulation()
	anims.active = false
	skeleton.animate_physical_bones = false
	
	if should_respawn:
		respawn_timer.start()
	is_dead = true


############################## Setter functions #########################################

#func set_y_rotation(new_rotation : float):
#	rotation.y = new_rotation
##	rotation.y = lerp_angle(rotation.y, new_rotation, 0.2)


func set_is_moving(value : bool):
	# A function to make sure movement anims are set only when move state changes, not every frame
	if is_moving != value:
		is_moving = value
	if is_moving:
		anims["parameters/Movement/playback"].travel("Character_Walk")
	else:
		anims["parameters/Movement/playback"].travel("Character_Idle2")
		anims.set("parameters/TimeScale/scale", 1.0)


func set_is_slipping(value) -> void:
	if not slip_timer.is_stopped():
		return
	is_slipping = value
	if value == true:
#		skeleton.physical_bones_start_simulation(["Physical Bone footR", "Physicla Bone footL", "Physical Bone shoulderR", "Physical Bone shoulderL"])
#		skeleton.physical_bones_start_simulation([])
#		skeleton.animate_physical_bones = false
		slip_timer.start()
		controller.set_process(false)
		controller.set_physics_process(false)
		var tween : Tween = create_tween()
		tween.tween_property(self, "rotation_degrees:x", 90, 0.1)
		tween.tween_property(self, "position:y", 0.1, 0.1)
		just_slipped = true
		await slip_timer.timeout
		set_is_slipping(false)
	else:
#		skeleton.physical_bones_stop_simulation()
#		skeleton.animate_physical_bones = true
		var tween : Tween = create_tween()
		tween.tween_property(self, "rotation_degrees:x", 0, 0.1)
		tween.tween_property(self, "position:y", 0, 0.1)
		controller.set_process(true)
		controller.set_physics_process(true)


func set_is_firing(value): 
	is_firing = value
	

#func set_is_paused(value):
#	is_paused = value
#	if value == true:
#		set_is_moving(false)
#		is_invincible = true
#	else:
#		is_invincible = false
	
	
func set_lives_left(amount) -> void:
	lives_left = amount
	if player_controlled:
		controller.update_hud(-1, -1, lives_left)
	
	if lives_left <= 0:
		should_respawn = false
		im_done_fer.emit(get_team())

####### Getter Functions ######

func get_health() -> int:
	return character_stats.current_health

func get_ammo() -> int:
	return character_stats.current_ammo

func get_speed() -> float:
	return character_stats.move_speed

func get_acceleration() -> float:
	return character_stats.acceleration

func get_team() -> String:
	return character_stats.Team


#### Signal functions ####

func _on_left_hook_body_entered(body):
	if body == self or hit_detected:
		return
	
	elif body.is_in_group("Level"):
		spawn_punch_particle(true)
	
	elif body is Character:
		if body.get_team() == get_team():
			return
		
		body.take_damage(character_stats.base_damage, self)
		body.apply_impulse(-transform.basis.z, character_stats.punch_force, 0.1)
		spawn_punch_particle(true)
#		$Human_Template_Male/metarig/Skeleton3D/LeftHookBone/ParticleSpawner2.spawn_particle()
		hit_detected = true
		left_hook.set_deferred("monitoring", false)
		if player_controlled:
			Engine.time_scale = 0.75


func _on_right_hook_body_entered(body):
	if body == self or hit_detected:
		return
	
	elif body.is_in_group("Level"):
		spawn_punch_particle(false)
	
	elif body is Character:
		if body.get_team() == get_team():
			return
		
		spawn_punch_particle(false)
		body.take_damage(character_stats.base_damage, self)
		body.apply_impulse(-transform.basis.z, character_stats.punch_force, 0.2)
#		$Human_Template_Male/metarig/Skeleton3D/RightHookBone/ParticleSpawner.spawn_particle()
		hit_detected = true
		right_hook.set_deferred("monitoring", false)


func spawn_punch_particle(left_hand : bool) -> void:
		punch_sound.play()
		var p = punch_particle.instantiate()
		add_child(p)
		p.set("transform/top_level", true)
		if left_hand:
			p.global_position = left_hook.global_position
		else:
			p.global_position = right_hook.global_position


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "Character_Attack_Left" or anim_name == "Character_Attack_Right":
#		print("anim finished")
		left_hook.set_deferred("monitoring", false)
		right_hook.set_deferred("monitoring", false)
		Engine.time_scale = 1
	elif anim_name == "Character_Block":
		is_blocking = false
	
	current_action = ""

########################## Projecile Functions ####################################
func spawn_projectile():
	var p : Projectile = projectile.instantiate()
	add_child(p)
	p.set_as_top_level(true)
#	if projectile_aimer.is_colliding():
#		projectile_placement.look_at(projectile_aimer.get_collision_point())
#		projectile_placement.rotation.x = default_projectile_x_rotation
	
#	print(projectile_placement.global_rotation)

	p.global_transform = projectile_placement.global_transform
	p.initiate(character_stats.projectile_damage, self)
	p.fire(determine_projectile_speed())
	
	projectile_placement.rotation = Vector3(deg_to_rad(default_projectile_x_rotation), 0, 0)


func determine_projectile_speed() -> float:
	var projectile_speed = character_stats.projectile_speed
	const FORWARD_SPEED = 1.25
	const BACKWARD_SPEED = 0.6
	
	# Increase speed if moving forward, decrease if backward
#	var projectile_speed_modifier : float = 1
	if move_direction > 0:
		projectile_speed *= BACKWARD_SPEED
	elif move_direction < 0:
		projectile_speed *= FORWARD_SPEED
	else:
		projectile_speed *= 1
	
	return projectile_speed

#### Misc functions ####

# One time function called on creation to set up character
func initiate():
	for node in get_children():
		if node.is_in_group("Controller"):
			controller = node
#			$ControllerPositioner.remote_path = node.get_path()
			break
	
	controller.initiate(self)
	
	if player_controlled:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	anims.active = true
#	skeleton.animate_physical_bones = true
	right_hook.monitoring = false
	left_hook.monitoring = false
	
	character_stats.current_health = character_stats.max_health
	character_stats.current_ammo = character_stats.max_ammo
	global_position = spawn_point
	
#	set_running(true)
	update_health()


func update_health():
	if player_controlled and controller:
		controller.update_hud(-1, get_health())
	
	health_changed.emit()


func respawn():
	var tween : Tween = create_tween()
	tween.tween_property(self, "global_position", spawn_point, 0.5)
	is_invincible = true
	await tween.finished
	invincibility_timer.start()

#	set_running(true)
	is_paused = false
	$CollisionShape3D.call_deferred("set_disabled", false)
	call_deferred("set_collision_layer_value", 2, true)
	call_deferred("set_collision_mask_value", 2, true)
	
	character_stats.current_ammo = character_stats.max_ammo
	character_stats.current_health = character_stats.max_health
	is_dead = false
	
	# Reset skeleton
	skeleton.physical_bones_stop_simulation()
	anims.active = true
	skeleton.animate_physical_bones = true
	skeleton.reset_bone_poses()
	
	current_action = ""
	
	if not player_controlled:
		controller.reset_ai()
	else:
		controller.update_hud(get_ammo(), get_health(), lives_left)
	
	$HealDetectArea.enable()
	respawn_complete.emit()
#	update_health()

#func set_running(value : bool) -> void:
#	set_process(value)
#	set_physics_process(value)
#	is_paused = !value
#	set_is_moving(value)
#	if controller:
#		controller.set_process(value)
#		controller.set_physics_process(value)
#	if value:
#		is_invincible = false
#	else:
#		is_invincible = true


func _on_invincibility_timer_timeout():
	is_invincible = false


func _on_punch_timer_timeout() -> void:
	left_hook.monitoring = false
	right_hook.monitoring = false
	current_action = ""
	controller.can_punch = true


func _on_impulse_timer_timeout() -> void:
	impulse_applied = false
	impulse_direction = Vector3.ZERO
	impulse_speed = 0


func _on_projectile_timer_timeout() -> void:
	controller.can_fire = true
