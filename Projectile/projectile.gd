class_name Projectile
extends RigidBody3D

@onready var lifespan_timer : Timer = $LifespanTimer


var speed : float = 0
var damage : int = 0
var status_effect

var did_i_hit : bool = false
var is_active : bool = true
var who_fired_me : Character = null
var previous_velocity : Vector3 = Vector3.ZERO


func fire(velocity : Vector3):
	apply_central_impulse(transform.basis.z * (speed + velocity.length()))


func initiate(new_speed : float, new_damage : int, requester : Character):
	speed = new_speed
	damage = new_damage
	who_fired_me = requester


func _physics_process(delta):
	if not did_i_hit:
		previous_velocity = linear_velocity
#		print(previous_velocity.length())


func _on_body_entered(body):
	did_i_hit = true
	if body.is_in_group("Floor"):
		is_active = false
	else:
		if body == who_fired_me or not is_active:
			did_i_hit = false
			return
		else:
#			print(previous_velocity.length())
#			print(linear_velocity.length())
			if body.has_method("take_projectile_damage") and not did_i_hit:
				body.take_projectile_damage(damage, status_effect)
				did_i_hit = true



func _on_lifespan_timer_timeout():
	queue_free()


func _on_sleeping_state_changed():
	is_active = false
