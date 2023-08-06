@icon("res://Characters/Bakery/BakerIcon.png")
class_name Baker
extends Character

@onready var frosting_gun : Node3D = $FrostingGun
@onready var material_overlay : ShaderMaterial = $NPC_Bakery_Male/Bakery_Male/Skeleton3D/Male_Bakery.material_overlay
var currently_firing : bool = false : set = set_currently_firing

func _ready() -> void:
	super()
	special_anims = $NPC_Bakery_Male/Bakery_Male/Skeleton3D/Male_Bakery/AnimationPlayer

func _handle_firing():
#	if is_paused:
#		return
	if projectile_timer.is_stopped():
		projectile_timer.start()
		frosting_gun.fire()
		character_stats.current_ammo -= 1
		if player_controlled:
			controller.update_hud(get_ammo())


func slather_em(target : Character):
	target.take_projectile_damage(character_stats.projectile_damage, self, "slow")
#	target.begin_slow_effect()


func die() -> void:
	super()
#	frosting_gun.particle.emitting = false
#	frosting_gun.set_physics_process(false)
#	frosting_gun.set_process(false)
	frosting_gun.cease_fire()


func respawn() -> void:
	super()
	frosting_gun.set_physics_process(true)
	frosting_gun.set_process(true)


func set_currently_firing(value : bool) -> void:
	currently_firing = value


func initiate() -> void:
	left_hook = $NPC_Bakery_Male/Bakery_Male/Skeleton3D/LeftHook/LeftHookArea
	right_hook = $NPC_Bakery_Male/Bakery_Male/Skeleton3D/RightHook/RightHookArea
	skeleton = $NPC_Bakery_Male/Bakery_Male/Skeleton3D
	anims.anim_player = $NPC_Bakery_Male/AnimationPlayer.get_path()
	super()


func _on_shader_stop_timer_timeout() -> void:
	material_overlay.set_shader_parameter("is_on", false)
