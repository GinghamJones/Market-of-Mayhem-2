class_name PlayerController
extends Node3D

var mouse_delta : Vector2 = Vector2.ZERO

@onready var hud : HUD = $HUD
@onready var raycast : RayCast3D = $RayCast3D

var look_speed : float = 0.3
const MAX_LOOK_ANGLE : int = 60
const MIN_LOOK_ANGLE : int = -60
const MAX_ZOOM: float = 5
const MIN_ZOOM : float = -1
var dodge_direction : Vector3 = Vector3.ZERO : get = get_dodge_direction

var controller_positioner : Node3D = null
var actor : Character = null
var target : Character = null
# Maybe I could figure out how to detect if player is fleeing??
var is_fleeing : bool = false

signal y_rotation_computed
signal direction_computed
signal request_action


func initiate(new_actor : Character):
	actor = new_actor
	controller_positioner = actor.get_node("ControllerPositioner")
	y_rotation_computed.connect(Callable(actor, "set_y_rotation"))
	direction_computed.connect(Callable(actor, "move_my_ass"))
	request_action.connect(Callable(actor, "request_action"))
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud.initiate(actor)


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.MOUSE_MODE_CAPTURED:
		mouse_delta = event.relative
	if event is InputEventJoypadMotion:
		mouse_delta = Vector2(JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y)
	
	if event.is_action_pressed("Dodge"):
#		emit_signal("dodge_em", get_direction())
		request_action.emit("Dodge")

#	if event.is_action_pressed("Jump"):
#		emit_signal("im_jumping")

	if event.is_action_pressed("Punch"):
#		emit_signal("punch_em")
		request_action.emit("Attack")
		
	if event.is_action_pressed("Block"):
#		emit_signal("block_me")
		request_action.emit("Block")
#	if event.is_action_released("Block"):
#		emit_signal("unblock_me")

	if event.is_action_pressed("FireProjectile"):
#		emit_signal("fire_projectile", true)
		if is_projectile_available():
			request_action.emit("Fire")
		
	if event.is_action_released("FireProjectile"):
#		emit_signal("quit_firing", false)
		request_action.emit("StopFire")
		
	if event.is_action_pressed("SpecialMelee"):
		if is_special_available():
#		emit_signal("use_super_move")
			request_action.emit("Special")
		
	if event.is_action_pressed("ToggleCursor"):
		handle_cursor()
	
	if event.is_action_pressed("StartRagdoll"):
		actor.die()
	
	if event.is_action_pressed("DebugCamera"):
		if $CameraSpringArm/Camera3D.current:
			get_tree().get_first_node_in_group("DebugCam").current = true
			$CameraSpringArm/Camera3D.current = false
		else:
			get_tree().get_first_node_in_group("DebugCam").current = false
			$CameraSpringArm/Camera3D.current = true
	
	if event.is_action_pressed("AICam"):
		if $CameraSpringArm/Camera3D.current:
			$CameraSpringArm/Camera3D.current = false
			get_tree().get_first_node_in_group("AICam").current = true
		else:
			get_tree().get_first_node_in_group("AICam").current = false
			$CameraSpringArm/Camera3D.current = true


func _process(delta: float) -> void:
	if actor:
		#Rotate camera
		rotation -= Vector3(mouse_delta.y, mouse_delta.x, 0) * look_speed * delta
		rotation.x = clamp(rotation.x, deg_to_rad(MIN_LOOK_ANGLE), deg_to_rad(MAX_LOOK_ANGLE))
		emit_signal("y_rotation_computed", get_y_rotation())
		
		mouse_delta = Vector2()
		
		global_position = controller_positioner.global_position
	else:
		pass


func run(delta : float):
	var new_direction : Vector3 = get_direction()
	
	if raycast.is_colliding():
			var dude = raycast.get_collider()
			if dude is Character:
				set_target(dude)
				hud.set_char_to_track(dude)
	
	direction_computed.emit(delta, new_direction)


func is_projectile_available() -> bool:
	if actor.get_ammo() <= 0 and not actor.projectile_timer.is_stopped():
		return false
	
	return true


func is_special_available() -> bool:
	if actor.special_timer.is_stopped():
		return true
	
	return false


func get_direction() -> Vector3:
	var input_dir : Vector2 = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBack")
	actor.move_direction = input_dir.y
	var direction : Vector3

	direction = (actor.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	return direction


func handle_cursor():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func update_hud(ammo : int = -1, health : int = -1, lives_left : int = -1):
	if ammo >= 0:
		hud.update_ammo(ammo)
	
	if health >= 0:
		hud.update_health(health)
	
	if lives_left >= 0:
		hud.update_lives_left(lives_left)


func get_y_rotation() -> float:
	return rotation.y


func set_target(new_target : Character):
	target = new_target

func get_fleeing() -> bool:
	return is_fleeing


func get_dodge_direction() -> Vector3:
	return get_direction()
