class_name Baker
extends Character

@onready var frosting_gun : Node3D = $FrostingGun


func _handle_firing():
	if projectile_timer.is_stopped():
		frosting_gun.fire()
		character_stats.current_ammo -= 1
		projectile_timer.start()

