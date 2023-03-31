class_name Character
extends CharacterBody3D

@export var character_stats : CharacterData

@onready var anims : AnimationTree = $AnimationTree
@onready var anim_mode = $AnimationTree.get("parameters/playback")
@onready var camera_control : Marker3D = $CamPositionHelper

var look_speed : float = 0.2
const MAX_LOOK_ANGLE : int = 60
const MIN_LOOK_ANGLE : int = -60
const MAX_ZOOM: float = 5
const MIN_ZOOM : float = -1
var new_rotation : float 

var mouse_delta : Vector2
var is_paused : bool = false
#var is_jumping : bool = false : set = set_is_jumping
var jump_force : float = 30

var player_controlled : bool : set = set_player_controlled
var controller


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Human_Template_Male.rotation_degrees.y = 180.0


func _process(delta: float) -> void:
	if not controller:
		return
	rotation.y = lerp_angle(rotation.y, controller.get_y_rotation(), 0.1)


func _physics_process(delta: float) -> void:
#	set_cam_position()
	move_my_ass(delta)


func move_my_ass(delta):
	if not controller:
		return
	var target_velocity : Vector3 = controller.get_velocity(character_stats.move_speed)
	
	if not is_on_floor():# and not is_jumping:
		target_velocity.y -= character_stats.gravity 
#	elif is_jumping and is_on_floor():
#		target_velocity.y += jump_force
#		if $JumpTimer.is_stopped():
#			set_is_jumping(false)
	else:
		target_velocity.y = 0
		
	velocity = lerp(velocity, target_velocity, character_stats.acceleration)
	if velocity.length() > 1.0:
		var anim_speed : float = velocity.length() * delta + 2
		anim_mode.travel("Character_Walk")
	else:
		anim_mode.travel("Character_Idle")
		
	move_and_slide()

func get_new_rotation(cam_rotation : float):
	new_rotation = cam_rotation


func jump():
	anim_mode.travel("Character_Backflip")

func punch():
	anim_mode.travel("Character_Attack")
	
func block():
	anim_mode.travel("Character_Block")
	
		

func set_anims(anim : String, anim_speed : float):
	pass


func set_player_controlled(how_bout_it : bool):
	if not how_bout_it:
		$CamPositionHelper.queue_free()
	
