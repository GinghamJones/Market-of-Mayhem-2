class_name Character
extends CharacterBody3D

@export var character_stats : CharacterData

@onready var anims : AnimationTree = $AnimationTree
@onready var anim_player : AnimationPlayer = $Human_Template_Male/AnimationPlayer
#@onready var camera_control : Marker3D = $CamPositionHelper

var look_speed : float = 0.2
const MAX_LOOK_ANGLE : int = 60
const MIN_LOOK_ANGLE : int = -60
const MAX_ZOOM: float = 5
const MIN_ZOOM : float = -1
var new_rotation : float 

var mouse_delta : Vector2
var is_paused : bool = false
var is_moving : bool = false : set = set_is_moving
	
#var is_jumping : bool = false : set = set_is_jumping
var jump_force : float = 30

#var player_controlled : bool : set = set_player_controlled
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
	if velocity.length() > 2.0:
		is_moving = true
		var anim_speed : float = velocity.length() * delta + 1.5
		anims.set("parameters/TimeScale/scale", anim_speed)
	else:
		is_moving = false
		anims["parameters/Movement/playback"].travel("Character_Idle")
		anims.set("parameters/TimeScale/scale", 1.1)
		
	move_and_slide()

func get_new_rotation(cam_rotation : float):
	new_rotation = cam_rotation


func jump():
	set_oneshot("parameters/JumpShot/request")

func punch():
	set_oneshot("parameters/PunchShot/request")

func block():
	set_oneshot("parameters/BlockShot/request")


func set_oneshot(anim : String):
	var oneshot_anims : Array = [anims["parameters/BlockShot/active"], anims["parameters/JumpShot/active"], anims["parameters/PunchShot/active"]]
	for oneshot in oneshot_anims:
		if oneshot == true:
			return
	
	anims.set(anim, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func set_is_moving(value : bool):
	if is_moving != value:
		is_moving = value
	if is_moving:
		anims["parameters/Movement/playback"].travel("Character_Walk")
	else:
		anims["parameters/Movement/playback"].travel("Character_Idle")
		anims.set("parameters/TimeScale/scale", 1.1)

#func set_player_controlled(how_bout_it : bool):
#	if not how_bout_it:
#		$CamPositionHelper.queue_free()
	
