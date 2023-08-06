@icon("res://Characters/Floral/FloralIcon.png")
class_name Florist
extends Character

func _ready() -> void:
	super()
	special_anims = $NPC_Checkstand_Female/Checkstand_Female/Skeleton3D/Female_Checkstand/AnimationPlayer


func initiate() -> void:
	left_hook = $NPC_Checkstand_Female/Checkstand_Female/Skeleton3D/LeftHook/LeftHookArea
	right_hook = $NPC_Checkstand_Female/Checkstand_Female/Skeleton3D/RightHook/RightHookArea
	skeleton = $NPC_Checkstand_Female/Checkstand_Female/Skeleton3D
	anims.anim_player = $NPC_Checkstand_Female/AnimationPlayer.get_path()
	super()


