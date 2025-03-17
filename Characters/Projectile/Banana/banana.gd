extends Projectile

@export var banana_peel : PackedScene


func fire(speed : float):
	super(speed)
	var peel : RigidBody3D = banana_peel.instantiate()
	get_tree().root.add_child(peel)
	peel.global_position = global_position
