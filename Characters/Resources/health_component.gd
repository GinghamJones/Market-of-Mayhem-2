class_name HealthComponent
extends Area3D

@onready var actor : Character = get_parent()
@export var max_health : int
var current_health : int
var is_invincible : bool = false

signal die


func _ready() -> void:
	current_health = max_health
	die.connect(Callable(actor, "die"))


func take_damage(damage : int, who_dunnit):
	if is_invincible:
		return

	current_health -= damage
	actor.update_health()
	
	if current_health <= 0:
		if who_dunnit is Manager:
			pass
		else:
			who_dunnit.set("score", 1)
		die.emit()


func take_projectile_damage(damage : int, who_dunnit : Character, status_effect : String = ""):
	if is_invincible:
		return
	
	if status_effect != "":
		actor.call(status_effect)
	
	current_health -= damage
	
	actor.update_health()
		
	if current_health <= 0:
		who_dunnit.set("score", 1)
		die.emit()


func reset() -> void:
	current_health = max_health
