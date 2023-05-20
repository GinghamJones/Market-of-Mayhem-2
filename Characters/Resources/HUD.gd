extends Control

@onready var ammo_bar : ProgressBar = $AmmoBar
@onready var ammo_text : Label = $AmmoCounter
@onready var health_bar : ProgressBar = $HealthBar
@onready var enemy_stats : Label = $EnemyStats
@onready var stats_hide_timer : Timer = $EnemyStats/Timer
var actor : Character
var char_to_track : Character = null : set = set_char_to_track

signal dude_forgotten

func _ready() -> void:
	dude_forgotten.connect(Callable(get_parent(), "set_target"))


func _physics_process(_delta):
	if char_to_track:
		update_enemy_stats()


func initiate(new_actor : Character):
	actor = new_actor
	
	ammo_bar.set("max_value", actor.character_stats.max_ammo)
	ammo_bar.set("value", actor.character_stats.current_ammo)

	ammo_text.text = "Ammo: " + str(actor.character_stats.current_ammo)
	
	health_bar.set("max_value", actor.character_stats.max_health)
	health_bar.set("value", actor.character_stats.current_health)


func update_ammo():
	ammo_bar.set("value", actor.character_stats.current_ammo)
	ammo_text.text = "Ammo: " + str(actor.character_stats.current_ammo)


func update_health():
	health_bar.set("value", actor.character_stats.current_health)


func update_enemy_stats():
	enemy_stats.show()
	enemy_stats.text = str(char_to_track.character_stats.Team) + "\t" + str(char_to_track.character_stats.current_health)


func hide_enemy_stats():
	enemy_stats.hide()
	char_to_track = null
	enemy_stats.text = "suck my dingus"
	dude_forgotten.emit(null)


func set_char_to_track(character : Character):
	char_to_track = character
	stats_hide_timer.start()
