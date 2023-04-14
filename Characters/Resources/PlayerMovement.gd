extends Node3D

var mouse_delta : Vector2 = Vector2.ZERO


var look_speed : float = 0.2
const MAX_LOOK_ANGLE : int = 60
const MIN_LOOK_ANGLE : int = -60
const MAX_ZOOM: float = 5
const MIN_ZOOM : float = -1

signal im_jumping
signal punch_em
signal block_me
signal unblock_me
signal fire_projectile
signal use_super_move
signal quit_firing

func _ready():
	im_jumping.connect(Callable(get_parent(), "jump"))
	punch_em.connect(Callable(get_parent(), "punch"))
	block_me.connect(Callable(get_parent(), "block"))
	unblock_me.connect(Callable(get_parent(), "unblock"))
	fire_projectile.connect(Callable(get_parent(), "set_is_firing"))
	use_super_move.connect(Callable(get_parent(), "use_super_move"))
	quit_firing.connect(Callable(get_parent(), "set_is_firing"))


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.MOUSE_MODE_CAPTURED:
		mouse_delta = event.relative
	if event is InputEventJoypadMotion:
		mouse_delta = Vector2(JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y)
	
	if event.is_action_pressed("Pause"):
		handle_pause()
	
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


func _process(delta: float) -> void:
	#Rotate camera
	rotation -= Vector3(mouse_delta.y, mouse_delta.x, 0) * look_speed * delta
	rotation.x = clamp(rotation.x, deg_to_rad(MIN_LOOK_ANGLE), deg_to_rad(MAX_LOOK_ANGLE))
	#emit_signal("rotation_changed", rotation.y)
	#global_position = get_parent().global_position

	mouse_delta = Vector2()

func get_velocity(speed) -> Vector3:
	var input_dir : Vector2 = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBack")
	var direction : Vector3 = (get_parent().transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var target_velocity : Vector3 = direction * speed

	return target_velocity

func handle_pause():
	SceneLoader.load_character_select()
	
	
		
func handle_cursor():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func get_y_rotation() -> float:
	return rotation.y
