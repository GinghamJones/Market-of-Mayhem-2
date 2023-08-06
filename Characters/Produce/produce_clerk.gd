@icon("res://Characters/Produce/ProduceIcon.png")
class_name Produce
extends Character

func _ready() -> void:
	super()
	special_anims = $NPC_Produce_Female/Produce_Female/Skeleton3D/Female_Produce/AnimationPlayer


func initiate() -> void:
	left_hook = $NPC_Produce_Female/Produce_Female/Skeleton3D/LeftHook/LeftHookArea
	right_hook = $NPC_Produce_Female/Produce_Female/Skeleton3D/RightHook/RightHookArea
	skeleton = $NPC_Produce_Female/Produce_Female/Skeleton3D
	anims.anim_player = $NPC_Produce_Female/AnimationPlayer.get_path()
	super()
