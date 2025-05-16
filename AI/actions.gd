class_name Actions
extends Node

@onready var actor : Character = get_parent().actor
@onready var controller : AIController2 = get_parent()
## Need access to proximity to target, projectile_available, punch_available, projectile_incoming, target_available
var actions : Dictionary = {
	"chase" : calculate_chase_score(),
	"wander" : calculate_wander_score(),
	"punch" : calculate_punch_score(),
	"dodge" : calculate_dodge_score(),
	"fire" : calculate_fire_score(),
	"retreat" : calculate_retreat_score(),
}

@export var PUNCH_MOD : float = 10
@export var DODGE_MULT : float = 100
@export var PROJECTILE_RANGE : float = 10.0
@export_range(0.3, 0.9, 0.05) var REACTION_UPPER_BOUND : float = 0.5
@export_range(0.1, 0.5, 0.05) var REACTION_LOWER_BOUND : float = 0.2
var reaction_time : float
var r : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	randomize()

func get_best_action() -> String:
	reaction_time = r.randf_range(REACTION_LOWER_BOUND, REACTION_UPPER_BOUND)
	var best_action : String = actions.keys()[0]
	var best_score : float = actions[best_action]
	for action : String in actions.keys():
		if actions[action] > best_score:
			best_action = action
			best_score = actions[action]
	return best_action
	
	
func calculate_chase_score() -> int:
	if not controller: return 0
	var target_available : bool = controller.target != null
	var proximity : float = (actor.global_position - controller.target.global_position).length()
	var chase_score : float = int(target_available) * proximity
	
	return chase_score


func calculate_wander_score() -> int:
	if not controller: return 0
	#!!! May want to make more sophisticated to include if others are around but not targets !!!#
	var target_available : bool = controller.target != null
	if target_available:
		return 0
	else:
		return 10000


func calculate_punch_score() -> int:
	if not controller: return 0
	var proximity : float = (actor.global_position - controller.target.global_position).length()
	var punch_available : int = int(actor.attack_component.can_punch)
	var is_target_visible : int = int(controller.is_target_visible())
	var punch_score : float = (2 / proximity) * PUNCH_MOD * punch_available * is_target_visible 
	return punch_score


func calculate_dodge_score() -> int:
	if not controller: return 0
	var is_projectile_incoming : int = int(controller.is_projectile_incoming())
	var dodge_score : float = is_projectile_incoming * reaction_time * DODGE_MULT
	return dodge_score


func calculate_fire_score() -> int:
	if not controller: return 0
	var is_projectile_available : int = int(actor.attack_component.can_fire)
	var is_target_in_range : int 
	var distance_to_target : float = (actor.global_position - controller.target.global_position).length()
	if distance_to_target < PROJECTILE_RANGE:
		is_target_in_range = 1
	else:
		is_target_in_range = 0
	var fire_score : float = is_projectile_available * is_target_in_range * reaction_time * (2 / distance_to_target)
	return fire_score


func calculate_retreat_score() -> int:
	if not controller: return 0
	var distance_to_target : float = (actor.global_position - controller.target.global_position).length()
	var can_punch : int = int(not actor.attack_component.can_punch)
	var too_many_dudes : int = int(controller.too_many_dudes)
	var retreat_score : float = (1 / distance_to_target) * can_punch * (too_many_dudes * 100)
	return retreat_score
