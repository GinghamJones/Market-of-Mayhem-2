class_name Character
extends CharacterBody3D

## You may find:
## Name generation in "initiate"

@export var character_stats : CharacterData
@export var projectile : PackedScene
#@onready var projectile_placement : Node3D = $Human_Template_Male/ProjectilePlacement

@onready var anims : AnimationTree = $CharacterAnimationTree
#@onready var anim_player : AnimationPlayer = $Human_Template_Male/AnimationPlayer
#@onready var right_hook : Area3D = $Human_Template_Male/metarig/Skeleton3D/RightHookBone/RightHook
#@onready var left_hook : Area3D = $Human_Template_Male/metarig/Skeleton3D/LeftHookBone/LeftHook
#@onready var skeleton : Skeleton3D = $Human_Template_Male/metarig/Skeleton3D
#@onready var mesh = $Human_Template_Male
@onready var anim_player = $NPC_Meat_Female/AnimationPlayer
@onready var right_hook = $NPC_Meat_Female/Meat_Female/Skeleton3D/RightHookAttachment/RightHook
@onready var left_hook = $NPC_Meat_Female/Meat_Female/Skeleton3D/LeftHookAttachment/LeftHook
@onready var skeleton = $NPC_Meat_Female/Meat_Female/Skeleton3D
@onready var mesh : MeshInstance3D = $NPC_Meat_Female/Meat_Female/Skeleton3D/Female_Meat
@onready var projectile_placement = $ProjectilePlacement

@onready var projectile_timer : Timer = $Timers/ProjectileTimer
@onready var special_timer : Timer = $Timers/SpecialMeleeTimer
@onready var jump_timer : Timer = $Timers/JumpTimer
@onready var dodge_timer : Timer = $Timers/DodgeTimer
@onready var dodge_cooldown : Timer = $Timers/DodgeCooldown
@onready var invincibility_timer : Timer = $Timers/InvincibilityTimer
@onready var punch_timer : Timer = $Timers/PunchTimer


var is_paused : bool = false : set = set_is_paused
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

var jump_force : float = 30
var dodge_direction : Vector3 = Vector3.ZERO
var hit_direction : Vector3 = Vector3.ZERO
var mouse_delta : Vector2 = Vector2.ZERO

var current_action : String = ""
var lives_left : int = 0

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


func _ready() -> void:
	randomize()

	character_stats.current_ammo = character_stats.max_ammo


func _physics_process(delta: float) -> void:
	if is_paused or not controller:
		return
	
#	if not player_controlled:
	controller.run(delta)
		
	if is_firing:
		_handle_firing()
#		if character_stats.single_fire:
#			is_firing = false


#### Movement functions ####

func move_my_ass(delta : float, direction : Vector3):
	if im_walloped:
		# Hit direction comes from the take_damage functiion
		velocity = hit_direction * character_stats.punch_force
		hit_direction = Vector3.ZERO
		im_walloped = false
	else:
		
		velocity = lerp(velocity, direction * get_speed(), get_acceleration())
		
		if not player_controlled:
			var nav_agent : NavigationAgent3D = controller.nav_agent
			nav_agent.set_velocity(velocity)
			await nav_agent.velocity_computed
			velocity = controller.get_velocity()
			
		if is_dodging:
			velocity = dodge_direction * character_stats.dodge_force
	
		handle_movement_anims(delta)
	
	if is_smacked:
		velocity = transform.basis.z * 75
		velocity.y += 15
	
	if not is_on_floor():
		velocity.y -= character_stats.gravity 
	else:
		velocity.y = 0
	move_and_slide()


func handle_movement_anims(delta : float):
	if velocity.length() > 2.0:
		set_is_moving(true)
		var anim_speed : float = velocity.length() * delta + 1.0
		anims.set("parameters/TimeScale/scale", anim_speed)
	else:
		set_is_moving(false)
#		anims["parameters/Movement/playback"].travel("Character_Idle")
#		anims.set("parameters/TimeScale/scale", 1.1)


#### Action functions ####

func start_dodge(new_direction : Vector3):
	if dodge_cooldown.is_stopped():
		dodge_timer.start()
		dodge_direction = new_direction
		is_dodging = true

func stop_dodge():
	dodge_cooldown.start()
	is_dodging = false


func request_action(action : String):
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
		attack()
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


func attack():
	if anims.set_oneshot("parameters/LeftAttackShot/request"):
		hit_detected = false
		right_hook.monitoring = true
		left_hook.monitoring = true
		punch_timer.start()


func block():
	if anims.set_oneshot("parameters/BlockShot/request"):
		is_blocking = true


func _handle_firing():
	# Overridden if Character is Baker or Freight
	if projectile_timer.is_stopped():
		projectile_timer.start()
		spawn_projectile()
		anims.set_oneshot("parameters/ProjectileShot/request")
		character_stats.current_ammo -= 1
		if player_controlled:
			controller.hud.update_ammo()
		if character_stats.single_fire:
			is_firing = false


func spawn_projectile():
	var p : Projectile = projectile.instantiate()
	add_child(p)
	p.set_as_top_level(true)
	p.global_transform = projectile_placement.global_transform
	p.initiate(character_stats.projectile_speed, character_stats.projectile_damage, self)
	p.fire(velocity)


func use_super_move():
	pass

#### Damage related functions ####

func take_damage(damage : int, direction : Vector3, who_dunnit):
	if is_invincible:
		return
	
	if is_blocking:
		character_stats.current_health -= damage - 5
	else:
		character_stats.current_health -= damage
		
		# Set im_walloped so phys_process can calculate punched velocity
		im_walloped = true
		hit_direction = direction
		
		update_health()
	
	if character_stats.current_health <= 0:
		if who_dunnit is Manager:
			pass
		else:
			who_dunnit.set("score", 1)
		die()


func take_projectile_damage(damage : int, status_effect, who_dunnit : Character):
	if is_invincible:
		return
	
	character_stats.current_health -= damage
	
	update_health()
		
	if character_stats.current_health <= 0:
		who_dunnit.set("score", 1)
		die()


func begin_slow_effect():
	$Timers/SlowTimer.start()
	character_stats.move_speed -= 2

func end_slow_effect():
	character_stats.move_speed += 2


func die():
	emit_signal("i_died", self)
	set_physics_process(false)
	set_process(false)
	
	if controller is AIController:
		controller.die()
	
	call_deferred("set_collision_layer_value", 2, false)
	call_deferred("set_collision_mask_value", 2, false)
#	$CollisionShape3D.call_deferred("set_disabled", true)
	
	# Activate ragdoll
	skeleton.physical_bones_start_simulation()
	skeleton.animate_physical_bones = false
	
	if should_respawn:
		$Timers/RespawnTimer.start()
	is_dead = true


#### Setter functions ####

func set_y_rotation(new_rotation : float):
	rotation.y = lerp_angle(rotation.y, new_rotation, 0.2)


#func set_oneshot(anim : String) -> bool:
#	# This checks if a oneshot is already playing and returns false if so. A false return stops the requested action from taking place.
#	var oneshot_anims : Array = [anims["parameters/BlockShot/active"], anims["parameters/LeftAttackShot/active"], 
#								anims["parameters/RightAttackShot/active"], anims["parameters/ProjectileShot/active"], anims["parameters/SpecialShot/active"]]
#	for oneshot in oneshot_anims:
#		if oneshot == true:
#			return false
#
#	anims.set(anim, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
#	return true


func set_is_moving(value : bool):
	# A function to make sure movement anims are set only when move state changes, not every frame
	if is_moving != value:
		is_moving = value
	if is_moving:
		anims["parameters/Movement/playback"].travel("Character_Walk")
	else:
		anims["parameters/Movement/playback"].travel("Character_Idle2")
		anims.set("parameters/TimeScale/scale", 1.0)


func set_is_firing(value): 
	is_firing = value
	

func set_is_paused(value):
	is_paused = value
	if value == true:
		set_is_moving(false)
		is_invincible = true
	else:
		is_invincible = false

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
	if body == self:
		return
	if body.has_method("take_damage") and not hit_detected:
		body.take_damage(character_stats.base_damage, -transform.basis.z.normalized(), self)
		$Human_Template_Male/metarig/Skeleton3D/LeftHookBone/ParticleSpawner2.spawn_particle()
		hit_detected = true
		left_hook.set_deferred("monitoring", false)


func _on_right_hook_body_entered(body):
	if body == self:
		return
	if body.has_method("take_damage") and not hit_detected:
		body.take_damage(character_stats.base_damage, -transform.basis.z.normalized(), self)
		$Human_Template_Male/metarig/Skeleton3D/RightHookBone/ParticleSpawner.spawn_particle()
		hit_detected = true
		right_hook.set_deferred("monitoring", false)


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "Character_Left_Attack":
		left_hook.set_deferred("monitoring", false)
		right_hook.set_deferred("monitoring", false)
	elif anim_name == "Character_Block":
		is_blocking = false
	
	current_action = ""


#### Misc functions ####

# One time function called on creation to set up character
func initiate():
	for node in get_children():
		if node.is_in_group("Controller"):
			controller = node
			$ControllerPositioner.remote_path = node.get_path()
			break
	
	controller.initiate(self)
	
	if player_controlled:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#	mesh.rotation_degrees.y = 180.0
	
	right_hook.monitoring = false
	left_hook.monitoring = false
	
	character_stats.current_health = character_stats.max_health
	character_stats.current_ammo = character_stats.max_ammo
	global_position = spawn_point
	
	update_health()


func update_health():
	if player_controlled and controller:
		controller.hud.update_health()


func respawn():
	var tween : Tween = create_tween()
	tween.tween_property(self, "global_position", spawn_point, 0.5)
	is_invincible = true
	invincibility_timer.start()
	await tween.finished
#	global_position = spawn_point
	set_physics_process(true)
	set_process(true)
#	$CollisionShape3D.call_deferred("set_disabled", false)
	call_deferred("set_collision_layer_value", 2, true)
	call_deferred("set_collision_mask_value", 2, true)
	character_stats.current_ammo = character_stats.max_ammo
	character_stats.current_health = character_stats.max_health
	is_dead = false
	
	# Reset skeleton
	skeleton.physical_bones_stop_simulation()
	skeleton.animate_physical_bones = true
	skeleton.reset_bone_poses()
	
	if not player_controlled:
		controller.reset_ai()
	respawn_complete.emit()
	update_health()


func _on_invincibility_timer_timeout():
	is_invincible = false


func _on_punch_timer_timeout() -> void:
	current_action = ""
