@icon("res://Characters/Meat/MeatIcon.png")
class_name MeatDude
extends Character

func _ready() -> void:
	super()
	special_anims = $NPC_Meat_Male/Meat_Male/Skeleton3D/Male_Meat/AnimationPlayer


func initiate() -> void:
	left_hook = $NPC_Meat_Male/Meat_Male/Skeleton3D/LeftHook/LeftHookArea
	right_hook = $NPC_Meat_Male/Meat_Male/Skeleton3D/RightHook/RightHookArea
	skeleton = $NPC_Meat_Male/Meat_Male/Skeleton3D
	anims.anim_player = $NPC_Meat_Male/AnimationPlayer.get_path()
	super()
