@icon("res://Characters/Kitchen/KitchenIcon.png")
class_name KitchenDude
extends Character

func initiate() -> void:
	anim_player = $NPC_Kitchen_Male/AnimationPlayer
	left_hook = $NPC_Kitchen_Male/Kitchen_Male/Skeleton3D/LeftHookAttachment/LeftHook
	right_hook = $NPC_Kitchen_Male/Kitchen_Male/Skeleton3D/RightHookAttachment/RightHook
	skeleton = $NPC_Kitchen_Male/Kitchen_Male/Skeleton3D
	mesh = $NPC_Kitchen_Male/Kitchen_Male/Skeleton3D/Male_Kitchen
	anims.anim_player = anim_player.get_path()
	super()
