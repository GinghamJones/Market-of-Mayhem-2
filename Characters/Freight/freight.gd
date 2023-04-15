class_name Freight
extends Character
@onready var lazer_timer : Timer = $Lazer/LazerTimer


func _handle_firing():
	$Lazer/LazerBeamRight.show()
	$Lazer/LazerBeamLeft.show()
	lazer_timer.start()
	
func stop_firing():
	$Lazer/LazerBeamRight.hide()
	$Lazer/LazerBeamLeft.hide()
