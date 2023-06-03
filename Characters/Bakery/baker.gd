@icon("res://Characters/Bakery/BakerIcon.png")
class_name Baker
extends Character

@onready var frosting_gun : Node3D = $FrostingGun


func _handle_firing():
#	if is_paused:
#		return
	if projectile_timer.is_stopped():
		projectile_timer.start()
		frosting_gun.fire()
		character_stats.current_ammo -= 1
		if player_controlled:
			controller.update_hud(get_ammo())


func slather_em(target):
	target.take_projectile_damage(character_stats.projectile_damage, null, self)
	target.begin_slow_effect()
