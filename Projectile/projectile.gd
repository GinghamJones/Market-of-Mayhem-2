class_name Projectile
extends RigidBody3D

@onready var lifespan_timer : Timer = $LifespanTimer

var damage : int = 0
var status_effect

var is_active : bool = true
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
	if body.is_in_group("Floor"):
		is_active = false
#		queue_free()
	elif body == who_fired_me:
		pass
	elif body.has_method("take_projectile_damage") and is_active:
		body.take_projectile_damage(damage, status_effect, who_fired_me)
		is_active = false
#		queue_free()


func _on_lifespan_timer_timeout():
	queue_free()


func _on_sleeping_state_changed():
	is_active = false
