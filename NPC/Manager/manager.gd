class_name Manager
extends CharacterBody3D


@onready var manager_anims : AnimationPlayer = $NPC_Manager/AnimationPlayer
#@onready var ai_tree = preload("res://NPC/Manager/manager_ai_tree.tscn")

var controller : AIController = null
@export var character_stats : CharacterData

var spawn_point : Vector3 = Vector3.ZERO

var player_in_hand : bool = false
#var should_respawn : bool = false
#var target : Character = null
#var is_dead : bool = false
var is_paused : bool = false


#func _process(_delta: float) -> void:
#	if not controller or player_in_hand:
#		return
#	rotation.y = lerp_angle(rotation.y, controller.get_y_rotation(), 0.2)


func _physics_process(delta: float) -> void:
	if is_paused:
		return
	
	controller.run(delta)
	
#	if not player_in_hand:
#		move_my_ass(delta)


func move_my_ass(delta : float, new_direction : Vector3):
	if not controller:
		return
	if not player_in_hand:
		velocity = lerp(velocity, new_direction * character_stats.move_speed, character_stats.acceleration)
		
		handle_movement_anims(delta)
		
		if not is_on_floor():
			velocity.y -= character_stats.gravity 
		
		velocity.y = 0
		move_and_slide()


func fuck_em_up(target : Character):
	player_in_hand = true
	target.is_paused = true
	manager_anims.play("Npc_Manager_Ruiner")
	manager_anims.speed_scale = 0.75
	await manager_anims.animation_finished
	player_in_hand = false
	target.is_paused = false
	target.take_damage(60, Vector3.ZERO, self)
	var new_timer : SceneTreeTimer = get_tree().create_timer(0.3)
	target.is_smacked = true
	await new_timer.timeout
	target.is_smacked = false


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
	controller.queue_free()
#	if should_respawn:
#		$Timers/RespawnTimer.start()
#	is_dead = true


func set_y_rotation(new_rotation : float):
	rotation.y = lerp_angle(rotation.y, new_rotation, 0.1)

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
