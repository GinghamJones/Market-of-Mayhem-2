class_name Manager
extends CharacterBody3D


@onready var manager_anims : AnimationPlayer = $NPC_Manager/AnimationPlayer
#@onready var ai_tree = preload("res://NPC/Manager/manager_ai_tree.tscn")

var controller : AIController = null
@export var character_stats : CharacterData

var spawn_point : Vector3 = Vector3.ZERO

var player_in_hand : bool = false
var should_respawn : bool = false
var target : Character = null
var is_dead : bool = false
var is_paused : bool = false


func _process(_delta: float) -> void:
	if not controller or player_in_hand:
		return
	rotation.y = lerp_angle(rotation.y, controller.get_y_rotation(), 0.2)


func _physics_process(delta: float) -> void:
	if is_paused:
		return
	
	controller.run()
	
	if not player_in_hand:
		move_my_ass(delta)


func move_my_ass(delta : float):
	if not controller:
		return
	var direction : Vector3 = controller.get_direction()
	
	if not is_on_floor():
		direction.y -= character_stats.gravity 

	direction.y = 0

	velocity = lerp(velocity, direction * character_stats.move_speed, character_stats.acceleration)

	handle_movement_anims(delta)

	move_and_slide()


func fuck_em_up(target : Character):
	player_in_hand = true
	target.is_paused = true
	manager_anims.play("Npc_Manager_Ruiner")
	manager_anims.speed_scale = 0.5
	await manager_anims.animation_finished
	player_in_hand = false
	target.set_velocity(transform.basis.z * 20)
	target.is_paused = false
	target.take_damage(60, Vector3.ZERO, self)


func take_damage(damage : int, _direction : Vector3, who_dunnit : Character):
	character_stats.current_health -= damage
	
	if character_stats.current_health <= 0:
		who_dunnit.set("score", 1)
		die()


func handle_movement_anims(delta : float):
	if velocity.length() > 2.0:
		manager_anims.play("Npc_MAnager_Walk")
		manager_anims.speed_scale = velocity.length() * delta + 2.0
	else:
		manager_anims.play("Character_Idle")
		manager_anims.speed_scale = 1.0


func die():
	set_physics_process(false)
	set_process(false)
	controller.set_detection(false)
	$CollisionShape3D.call_deferred("set_disabled", true)
	$NPC_Manager/Npc_Manager/Skeleton3D.physical_bones_start_simulation()
	$NPC_Manager/Npc_Manager/Skeleton3D.animate_physical_bones = false
	if should_respawn:
		$Timers/RespawnTimer.start()
	is_dead = true


func respawn():
	global_position = spawn_point
	set_physics_process(true)
	set_process(true)
	$CollisionShape3D.call_deferred("set_disabled", false)
	is_dead = false
	$NPC_Manager/Npc_Manager/Skeleton3D.physical_bones_stop_simulation()
	$NPC_Manager/Npc_Manager/Skeleton3D.animate_physical_bones = true
	$NPC_Manager/Npc_Manager/Skeleton3D.reset_bone_poses()

func get_speed() -> float:
	return character_stats.move_speed

func get_health() -> int:
	return character_stats.current_health

func get_team() -> String:
	return character_stats.Team

func initiate():
	for node in get_children():
		if node.is_in_group("Controller"):
			controller = node
#			controller.actor = self
			controller.initiate(self)
			$ControllerPositioner.remote_path = node.get_path()
			break
			
	character_stats.current_health = character_stats.max_health
	global_position = spawn_point
