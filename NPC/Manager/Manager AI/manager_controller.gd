class_name ManagerController
extends Node3D

@onready var manager_ai_module : PackedScene = preload("res://NPC/Manager/Manager AI/manager_ai_module.tscn")
@onready var detection_field : Area3D = $DetectionField
@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D

var actor = null
var target : Character = null
var controller_positioner : Node3D = null
var cur_ai = null
var direction : Vector3 = Vector3.ZERO : set = set_direction, get = get_direction
var y_rotation : float = 0 : set = set_y_rotation, get = get_y_rotation

#var queued_action : String = ""
#var is_waiting_to_act : bool = false
var current_timer : Timer = null

signal y_rotation_computed
signal direction_computed


func initiate(new_actor) -> void:
	actor = new_actor
	controller_positioner = actor.get_node("ControllerPositioner")
	detection_field.set_actor(actor)
	y_rotation_computed.connect(Callable(actor, "set_y_rotation"))
	direction_computed.connect(Callable(actor, "move_my_ass"))
	
	var new_module = manager_ai_module.instantiate()
	add_child(new_module)
	cur_ai = new_module


func run(delta : float):
	if actor:
		if current_timer:
			await current_timer.timeout
			current_timer = null
		cur_ai.run(self)
		var new_direction : Vector3 = get_direction()
		emit_signal("direction_computed", delta, new_direction)


func grab_target():
	actor.fuck_em_up(target)


func move_to_target():
	set_direction((nav_agent.get_next_path_position() - actor.global_position).normalized())
	
	if target:
		set_nav_target(target.global_position)
		face_enemy()
	else:
		face_move_direction()


func face_enemy():
	if target:
		var new_direction = target.global_position - actor.global_position
		var angle = atan2(-new_direction.x, -new_direction.z)
		set_y_rotation(angle)
	else:
		# Just in case...
		face_move_direction()


func face_move_direction():
	var cur_direction : Vector3 = get_direction()
	var new_rotation : float = atan2(-cur_direction.x, -cur_direction.z)
	set_y_rotation(new_rotation)


func is_target_in_grab_distance() -> bool:
	if detection_field.am_i_facing_target(target.global_position):
		if (target.global_position - actor.global_position).length() <= 1.0:
			return true
		else:
			return false
	
	return false


func set_nav_target(new_target : Vector3):
	nav_agent.set_target_position(new_target)


func set_direction(value : Vector3) -> void:
	direction = value


func set_y_rotation(value : float) -> void:
	y_rotation = value
	emit_signal("y_rotation_computed", y_rotation)


func get_y_rotation() -> float:
	return y_rotation

func get_direction() -> Vector3:
	return direction


func get_actor_speed() -> float:
	return actor.get_speed()
