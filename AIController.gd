extends Node3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D


enum {WANDERING, PURSUING, FLEEING, ATTACKING, THINKING}
var target_state : int = WANDERING
var movement_state : int = WANDERING
var attack_state : int = WANDERING


func check_wander_target():
	if nav_agent.is_navigation_finished():
		while(true):
			var radius : float = 50.0
			var random_position = Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))
			if random_position < Vector3(1, 0, 1) and random_position > Vector3(-1, 0, -1):
				# Check if near center of map and give asinine target if so to get new target
				set_nav_target(Vector3(1000, 234, 2343))
			else:
				set_nav_target(random_position)
			if nav_agent.is_target_reachable():
				break


func set_nav_target(new_target : Vector3):
	nav_agent.set_target_position(new_target)
