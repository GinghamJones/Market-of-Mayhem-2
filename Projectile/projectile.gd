class_name Projectile
extends RigidBody3D

@onready var lifespan_timer : Timer = $LifespanTimer

var damage : int = 0
@export var status_effect : String = ""

var is_active : bool = true : set = set_is_active
var who_fired_me : Character = null
#var previous_velocity : Vector3 = Vector3.ZERO


func fire(speed : float):
	apply_central_impulse(transform.basis.z * speed)


func initiate(new_damage : int, requester : Character):
	damage = new_damage
	who_fired_me = requester


#func _physics_process(delta):
#	if is_active:
#		previous_velocity = linear_velocity
##		print(previous_velocity.length())


func _on_body_entered(body):
	if body is Character:
		if body.get_team() == who_fired_me.get_team():
			pass
		else:
			$ImpactSound.play()
			body.take_projectile_damage(damage, who_fired_me, status_effect)
	else:
		$ImpactSound.play()
		set_is_active(false)


func set_is_active(value : bool) -> void:
	is_active = value
	if value == false:
		set_deferred("contact_monitor", false)


func _on_lifespan_timer_timeout():
	queue_free()

