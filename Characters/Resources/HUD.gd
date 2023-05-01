extends Control

@onready var ammo_bar : ProgressBar = $AmmoBar
@onready var ammo_text : Label = $AmmoCounter
@onready var health_bar : ProgressBar = $HealthBar
@onready var enemy_stats : Label = $EnemyStats
@onready var stats_hide_timer : Timer = $EnemyStats/Timer
var actor : Character


func initiate():
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


func update_enemy_stats(dude : Character):
	enemy_stats.show()
	enemy_stats.text = str(dude.character_stats.Team) + "\t" + str(dude.character_stats.current_health)
	stats_hide_timer.start()
	

func hide_enemy_stats():
	enemy_stats.hide()
	enemy_stats.text = "suck my dingus"
