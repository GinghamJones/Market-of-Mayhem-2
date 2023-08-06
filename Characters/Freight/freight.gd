class_name Freight
extends Character

@onready var lazer_tree = $Lazer

func _ready():
	super()
	lazer_tree.connect("colliding", Callable(self, "deal_lazer_damage"))
	special_anims = $NPC_Feight_Male/Freight_Male/Skeleton3D/Male_Freight/AnimationPlayer


func _handle_firing():
#	if is_paused:
#		return
	if projectile_timer.is_stopped():
		lazer_tree.activate(0.5)
		projectile_timer.start()


func stop_firing():
#	if is_paused:
#		return
	lazer_tree.deactivate(0.3)


func deal_lazer_damage(enemy : Character):
	enemy.take_projectile_damage(character_stats.projectile_damage, self)


func die() -> void:
	super()
	lazer_tree.set_physics_process(false)
	lazer_tree.set_process(false)


func respawn() -> void:
	super()
	lazer_tree.set_physics_process(true)
	lazer_tree.set_process(true)


func initiate() -> void:
	left_hook = $NPC_Feight_Male/Freight_Male/Skeleton3D/LeftHook/Area3D
	right_hook = $NPC_Feight_Male/Freight_Male/Skeleton3D/RightHook/Area3D
	skeleton = $NPC_Feight_Male/Freight_Male/Skeleton3D
	anims.anim_player = $NPC_Feight_Male/AnimationPlayer.get_path()
	super()
