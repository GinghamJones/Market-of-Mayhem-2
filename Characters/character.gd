class_name Character
extends CharacterBody3D

## You may find:
## Name generation in "initiate"

## Need to be set for each Character type ##
@export var character_stats : CharacterData
@export var skeleton : Skeleton3D
@export var mesh : MeshInstance3D
@export var special_attach : Node3D
@export var attack_component : AttackComponent
@export var health_component : HealthComponent

@onready var anims : AnimationTree = $CharacterAnimationTree
@onready var controller_positioner: Node3D = $ControllerPositioner


## Timers ##
@onready var dodge_timer : Timer = $Timers/DodgeTimer
@onready var dodge_cooldown : Timer = $Timers/DodgeCooldown
@onready var invincibility_timer : Timer = $Timers/InvincibilityTimer
@onready var punch_timer : Timer = $Timers/PunchTimer
@onready var heal_delay_timer: Timer = $Timers/HealDelayTimer
@onready var respawn_timer: Timer = $Timers/RespawnTimer
@onready var slip_timer: Timer = $Timers/SlipTimer
@onready var impulse_timer: Timer = $Timers/ImpulseTimer

var is_paused : bool = false
var is_dodging : bool = false
var is_moving : bool = false : set = set_is_moving

var im_walloped : bool = false
var is_invincible : bool = false
var is_dead : bool = false
var is_smacked : bool = false
var should_respawn : bool = true
var is_slowed : bool = false
var is_healing : bool = false
var is_slipping : bool = false : set = set_is_slipping
var impulse_applied : bool = false
var just_slipped : bool = false

var impulse_direction : Vector3 = Vector3.ZERO
var impulse_speed : float = 0
var move_direction : int = 0
var jump_force : float = 30
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
	is_paused = true
	randomize()


func _physics_process(delta: float) -> void:
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
	
	controller.run(delta)
	
	if is_healing:
		if heal_delay_timer.is_stopped():
			heal_delay_timer.start()


########################## Movement functions ###########################################

func move_my_ass(delta : float, direction : Vector3):
	if impulse_applied:
		velocity = impulse_direction * impulse_speed
		# Maybe??
		set_is_moving(false)
		move_and_slide()
		return
	else:
		velocity = lerp(velocity, direction * get_speed(), get_acceleration())

		if velocity.length() > get_speed():
			velocity = velocity.normalized() * get_speed()

		if is_dodging:
			velocity = dodge_direction * character_stats.dodge_force

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
#		anims["parameters/Movement/playback"].travel("Character_Idle")
#		anims.set("parameters/TimeScale/scale", 1.1)


############################## Action functions #############################################

func request_action(action : String):
	if current_action == "dead" or is_paused: return
	
	if action == "StopFire":
		#is_firing = false
		current_action = ""
		return
	if action == "Dodge":
		if current_action == "Block" or current_action == "Punch":
			return
		
		#start_dodge(controller.get_dodge_direction())
		start_dodge(Vector3.ZERO)
		return
			
	if current_action != "":
		return
	
	if action == "Attack":
		if not attack_component:
			return
		var punch_type : int = attack_component.punch()
		attack(punch_type)
	elif action == "Fire":
		if not attack_component:
			return
		#is_firing = true
		attack_component.fire()
	#elif action == "Special":
		#use_super_move()
	else:
		print("i don't understand yer action...")
		print(action)
	
	current_action = action


func start_dodge(new_direction : Vector3):
	if dodge_cooldown.is_stopped():
		dodge_timer.start()
		#dodge_direction = new_direction
		dodge_direction = velocity.normalized()
		is_dodging = true

func stop_dodge():
	dodge_cooldown.start()
	is_dodging = false


func attack(punch_type : int):
	# Now just for handling visual animations. Actual attack in AttackComponent
	if punch_type == AttackComponent.Punch_States.CANT_PUNCH:
		return
	
	if punch_type == attack_component.Punch_States.PUNCHED_LEFT:
		anims.set_oneshot("parameters/LeftAttackShot/request")
	else:
		anims.set_oneshot("parameters/RightAttackShot/request")
	punch_timer.start()


func _handle_firing():
	if attack_component.fire():
		anims.set_oneshot("parameters/ProjectileShot/request")

#func use_super_move():
	#if anims.set_oneshot("parameters/SpecialShot/request"):
		##special_timer.start()
		#var s = special.instantiate()
		#special_attach.add_child(s)
		#await anims.animation_finished
		#s.queue_free()
		
	

############################## Damage related functions ###########################################

#!!! This will be in HealthComponent !!!#
func take_damage(damage : int, who_dunnit):
	if is_invincible:
		return

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
	
	if status_effect != "":
		call(status_effect)
	
	character_stats.current_health -= damage
	
	update_health()
		
	if character_stats.current_health <= 0:
		who_dunnit.set("score", 1)
		die()


func slow():
	if not is_slowed:
		$Timers/SlowTimer.start()
		character_stats.move_speed -= 4
		is_slowed = true


func end_slow_effect():
	character_stats.move_speed += 4


func heal() -> void:
	if health_component.current_health < health_component.max_health:
		health_component.current_health += 5
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

func set_y_rotation(new_rotation : float):
	rotation.y = lerp_angle(rotation.y, new_rotation, 0.2)


func set_is_moving(value : bool):
	# A function to make sure movement anims are set only when move state changes, not every frame
	if is_moving != value:
		is_moving = value
	else:
		return
	
	if value:
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
	# Temporary fix #
	return health_component.current_health

func get_ammo() -> int:
	# Temporary fix #
	return attack_component.current_ammo

func get_speed() -> float:
	return character_stats.move_speed

func get_acceleration() -> float:
	return character_stats.acceleration

func get_team() -> String:
	return character_stats.Team


#### Signal functions ####

func _on_animation_tree_animation_finished(anim_name):
	current_action = ""


#### Misc functions ####

# One time function called on creation to set up character
func initiate():
	for node in get_children():
		if node.is_in_group("Controller"):
			controller = node
			break
	
	controller.initiate(self)
	anims.active = true
	global_position = spawn_point

	update_health()


func update_health():
	if player_controlled and controller:
		controller.update_hud(-1, health_component.current_health)
	
	health_changed.emit()


func respawn():
	var tween : Tween = create_tween()
	tween.tween_property(self, "global_position", spawn_point, 0.5)
	is_invincible = true
	await tween.finished
	invincibility_timer.start()

	is_paused = false
	$CollisionShape3D.call_deferred("set_disabled", false)
	call_deferred("set_collision_layer_value", 2, true)
	call_deferred("set_collision_mask_value", 2, true)
	
	attack_component.reset()
	health_component.reset()
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


func _on_invincibility_timer_timeout():
	is_invincible = false


func _on_punch_timer_timeout() -> void:
	current_action = ""


func _on_impulse_timer_timeout() -> void:
	impulse_applied = false
	impulse_direction = Vector3.ZERO
	impulse_speed = 0
