class_name Freight
extends Character

#@onready var lazer_tree = $Lazer


#func _ready():
	#super()
	#lazer_tree.connect("colliding", Callable(self, "deal_lazer_damage"))


#func _handle_firing():
##	if is_paused:
##		return
	#if projectile_timer.is_stopped():
		#lazer_tree.activate(0.5)
		#projectile_timer.start()


#func stop_firing():
##	if is_paused:
##		return
	#lazer_tree.deactivate(0.3)


#func deal_lazer_damage(enemy : Character):
	#enemy.take_projectile_damage(character_stats.projectile_damage, self)


#func die() -> void:
	#super()
	#lazer_tree.set_physics_process(false)
	#lazer_tree.set_process(false)


#func respawn() -> void:
	#super()
	#lazer_tree.set_physics_process(true)
	#lazer_tree.set_process(true)
