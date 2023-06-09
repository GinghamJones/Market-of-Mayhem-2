class_name HUD
extends Control

@onready var ammo_bar : ProgressBar = $AmmoBar
@onready var ammo_text : Label = $AmmoBar/AmmoCounter
@onready var projectile_cooldown_bar : ProgressBar = $ProjectileCooldown
@onready var projectile_cooldown_text : Label = $ProjectileCooldown/TimeLeft
@onready var special_cooldown_bar : ProgressBar = $SpecialCooldown
@onready var special_cooldown_text : Label = $SpecialCooldown/TimeLeft
@onready var health_bar : ProgressBar = $HealthBar
@onready var enemy_health_text : Label = $EnemyHealth/EnemyHealthText
@onready var enemy_health_bar : ProgressBar = $EnemyHealth
@onready var stats_hide_timer : Timer = $EnemyHealth/EnemyHealthText/Timer

var special_timer : Timer = null
var projectile_timer : Timer = null
var actor : Character
var char_to_track : Character = null : set = set_char_to_track

signal dude_forgotten

func _ready() -> void:
	dude_forgotten.connect(Callable(get_parent(), "set_target"))


func _physics_process(_delta):
	if char_to_track:
		if char_to_track.health_changed:
			update_enemy_stats(char_to_track.get_team(), char_to_track.get_health())
	
	if not special_timer.is_stopped():
		update_special(special_timer.time_left)
	
	if not projectile_timer.is_stopped():
		update_projectile_cooldown()


func initiate(new_actor : Character):
	actor = new_actor
	special_timer = actor.special_timer
	projectile_timer = actor.projectile_timer
	
	projectile_cooldown_bar.set("max_value", projectile_timer.wait_time)
	projectile_cooldown_bar.set("value", 0)
	projectile_cooldown_text.text = str(0)
	
	ammo_bar.set("max_value", actor.character_stats.max_ammo)
	ammo_bar.set("value", actor.character_stats.current_ammo)

	ammo_text.text = "Ammo: " + str(actor.character_stats.current_ammo)
	
	special_cooldown_bar.set("max_value", actor.special_timer.wait_time)
	special_cooldown_bar.set("value", 0)
	special_cooldown_text.text = str(0)
	
	health_bar.set("max_value", actor.character_stats.max_health)
	health_bar.set("value", actor.character_stats.current_health)


func update_projectile_cooldown() -> void:
	var time_left = projectile_timer.time_left
	projectile_cooldown_bar.set("value", time_left)
	projectile_cooldown_text.text = str(time_left)


func update_ammo(value : int):
	ammo_bar.set("value", value)
	ammo_text.text = "Ammo: " + str(value)


func update_health(value : int):
	health_bar.set("value", value)


func update_special(value : float):
#	var time_left : float = special_timer.time_left
	special_cooldown_bar.set("value", value)
	special_cooldown_text.text = str(value)


func update_lives_left(value : int):
	$LivesLeft.text = "Lives: " + str(value)


func update_enemy_stats(team : String, value : int):
	enemy_health_text.show()
	enemy_health_bar.show()
	enemy_health_text.text = team + "\t" + str(value)
	enemy_health_bar.set("value", value)


func hide_enemy_stats():
	enemy_health_text.hide()
	enemy_health_bar.hide()
	char_to_track = null
	enemy_health_text.text = "suck my dingus"
	dude_forgotten.emit(null)


func set_char_to_track(character : Character):
	char_to_track = character
	stats_hide_timer.start()
