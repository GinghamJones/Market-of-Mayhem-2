extends Projectile

@onready var banana_peel : PackedScene = preload("res://Projectile/Banana/banana_peel.tscn")


func fire(velocity : Vector3):
	super(velocity)
	var peel : RigidBody3D = banana_peel.instantiate()
	get_tree().root.add_child(peel)
	peel.global_position = global_position
