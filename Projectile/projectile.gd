class_name Projectile
extends RigidBody3D

@onready var lifespan_timer : Timer = $LifespanTimer


var speed : float = 0
var damage : int = 0
var status_effect

var did_i_hit : bool = false
var who_fired_me : Character = null


func fire():
	apply_central_impulse(transform.basis.z * speed)


func initiate(new_speed : float, new_damage : int, requester : Character):
	speed = new_speed
	damage = new_damage
	who_fired_me = requester


func _on_body_entered(body):
	if body == who_fired_me:
		pass
	else:
		if body.has_method("take_projectile_damage") and not did_i_hit:
			body.take_projectile_damage(damage, status_effect)
			did_i_hit = true
			


func _on_lifespan_timer_timeout():
	queue_free()