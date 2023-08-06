extends Projectile

@onready var banana_peel : PackedScene = preload("res://Projectile/Banana/banana_peel.tscn")


func fire(velocity_multiplier : float):
	super(velocity_multiplier)
	var peel : RigidBody3D = banana_peel.instantiate()
	get_tree().root.add_child(peel)
	peel.global_transform = global_transform
