class_name PlayerController
extends Node3D

var mouse_delta : Vector2 = Vector2.ZERO

@onready var hud = $HUD
@onready var raycast : RayCast3D = $RayCast3D

var look_speed : float = 0.2
const MAX_LOOK_ANGLE : int = 60
const MIN_LOOK_ANGLE : int = -60
const MAX_ZOOM: float = 5
const MIN_ZOOM : float = -1

var actor : Character = null
var target : Character = null
# Maybe I could figure out how to detect if player is fleeing??
var fleeing : bool = false

signal im_jumping
signal punch_em
signal block_me
signal unblock_me
signal fire_projectile
signal use_super_move
signal quit_firing
signal dodge_em


func initiate(new_actor : Character):
	actor = new_actor
	
	im_jumping.connect(Callable(actor, "jump"))
	punch_em.connect(Callable(actor, "punch"))
	block_me.connect(Callable(actor, "block"))
	unblock_me.connect(Callable(actor, "unblock"))
	fire_projectile.connect(Callable(actor, "set_is_firing"))
	use_super_move.connect(Callable(actor, "use_super_move"))
	quit_firing.connect(Callable(actor, "set_is_firing"))
	dodge_em.connect(Callable(actor, "start_dodge"))
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud.initiate(actor)


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.MOUSE_MODE_CAPTURED:
		mouse_delta = event.relative
	if event is InputEventJoypadMotion:
		mouse_delta = Vector2(JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y)
	
	if event.is_action_pressed("Dodge"):
		emit_signal("dodge_em", get_direction())
	if event.is_action_pressed("Jump"):
		emit_signal("im_jumping")

	if event.is_action_pressed("Punch"):
		emit_signal("punch_em")
		
	if event.is_action_pressed("Block"):
		emit_signal("block_me")
#	if event.is_action_released("Block"):
#		emit_signal("unblock_me")

	if event.is_action_pressed("FireProjectile"):
		emit_signal("fire_projectile", true)
	if event.is_action_released("FireProjectile"):
		emit_signal("quit_firing", false)
		
	if event.is_action_pressed("SpecialMelee"):
		emit_signal("use_super_move")
		
	if event.is_action_pressed("ToggleCursor"):
		handle_cursor()
	
	if event.is_action_pressed("DebugCamera"):
		if $SpringArm3D/Camera3D.current:
			get_tree().get_first_node_in_group("DebugCam").current = true
			$SpringArm3D/Camera3D.current = false
		else:
			get_tree().get_first_node_in_group("DebugCam").current = false
			$SpringArm3D/Camera3D.current = true


func _process(delta: float) -> void:
	if actor:
		#Rotate camera
		rotation -= Vector3(mouse_delta.y, mouse_delta.x, 0) * look_speed * delta
		rotation.x = clamp(rotation.x, deg_to_rad(MIN_LOOK_ANGLE), deg_to_rad(MAX_LOOK_ANGLE))

		mouse_delta = Vector2()
		
		if raycast.is_colliding():
			var dude = raycast.get_collider()
			if dude is Character:
				set_target(dude)
				hud.set_char_to_track(dude)
	else:
		pass


func get_direction() -> Vector3:
	var input_dir : Vector2 = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBack")
	var direction : Vector3

	direction = (actor.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#var target_velocity : Vector3 = direction

	return direction


func handle_cursor():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func get_y_rotation() -> float:
	return rotation.y


func set_target(new_target : Character):
	target = new_target


func get_fleeing() -> bool:
	return fleeing
