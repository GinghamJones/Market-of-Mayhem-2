class_name Freight
extends Character
@onready var lazer_timer : Timer = $Lazer/LazerTimer
@onready var damage_limiter : Timer = $Lazer/DamFrequencyLimit
@onready var lazer : RayCast3D = $Lazer/LazerHitDetect


func _ready():
	super()
	lazer.enabled = false

func _handle_firing():
	$Lazer/LazerBeamRight.show()
	$Lazer/LazerBeamLeft.show()
	lazer.enabled = true
	lazer_timer.start()
	damage_limiter.start()
	
	
func stop_firing():
	$Lazer/LazerBeamRight.hide()
	$Lazer/LazerBeamLeft.hide()
	lazer.enabled = false


func deal_lazer_damage():
	if lazer.is_colliding():
		var collider : Character = lazer.get_collider()
		if collider.character_stats.Team != "Freight":
			collider.take_projectile_damage(character_stats.projectile_damage, null, self)
			damage_limiter.start()
