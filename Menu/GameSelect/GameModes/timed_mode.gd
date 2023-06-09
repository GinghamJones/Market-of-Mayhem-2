class_name TimedMode
extends GameMode

@onready var round_timer : Timer = $Timers/RoundTimer
@onready var round_time_left : Label = $GUI/RoundTimeLeft
@onready var manager_spawn_timer: Timer = $Timers/ManagerSpawnTimer


func _ready():
	super()
#	call_deferred("spawn_bots")
	await get_tree().process_frame
	spawn_players()
	pause_characters()
	await get_tree().process_frame
	$GUI.populate_scoreboard(current_characters)
	start_round()


func _process(delta):
	super(delta)
	if not round_timer.is_stopped():
		round_time_left.text = time_convert(int(round_timer.time_left)) 


func start_round():
#	reset_characters()
	pause_characters()
#	get_tree().paused = true
	current_round += 1
	countdown_text.show()
	start_timer.start()
	manager_spawn_timer.wait_time = randf_range(10, 30)
	
	await start_timer.timeout
	
	countdown_text.hide()
	
	manager_spawn_timer.start()
	unpause_characters()
	round_timer.start()
	round_time_left.show()


func end_round():
	if current_round < max_rounds:
		scoreboard.show()
		kill_em_all()
		
		intermission_timer.start()
		intermission_text.show()
		round_time_left.hide()
		
		await intermission_timer.timeout
		
		intermission_text.hide()
		scoreboard.hide()
		reset_characters()
		manager.queue_free()
		manager = null
		start_round()
	
	else:
		kill_em_all()
		scoreboard.show()
		intermission_timer.start()
		intermission_text.show()
		
		await intermission_timer.timeout
		
		intermission_text.hide()
		emit_signal("load_character_select")


func spawn_players():
	var teams : Array = ["Bakery", "Floral", "Meat", "Cashier", "Kitchen", "Produce", "Freight",]
	
	add_character(player_character_type, true, player_name)
	
	for t in teams:
		var chars_to_spawn : int = 3
		if player_character_type == t:
			chars_to_spawn = 2
			
		for i in chars_to_spawn:
			add_character(t, false)
	
#	reset_characters()
	# Delete this for real game
#	manager = SpawnManager.get_new_manager()
#	add_child(manager)
#	manager.initiate()

func kill_em_all() -> void:
	for key in current_characters.keys():
		for dude in current_characters[key]:
			if not dude.respawn_timer.is_stopped():
				dude.respawn_timer.stop()
			dude.should_respawn = false
			dude.die()


func time_convert(time_in_sec) -> String:
	var seconds = time_in_sec % 60
	var minutes = (time_in_sec/60) % 60

	#returns a string with the format "HH:MM:SS"
	return "%02d:%02d" % [minutes, seconds]


func reset_characters() -> void:
	for key in current_characters.keys():
		for dude in current_characters[key]:
			dude.respawn()
			dude.set_lives_left(1000)
			if dude.player_controlled == false:
				dude.controller.reset_ai()
#			dude.set_running(false)
			dude.is_paused = true
			dude.should_respawn = true


func pause_characters() -> void:
	for key in current_characters.keys():
		for dude in current_characters[key]:
#			dude.set_running(false)
			dude.is_paused = true
			dude.set_process(false)
			dude.set_physics_process(false)


func unpause_characters() -> void:
	for key in current_characters.keys():
		for dude in current_characters[key]:
#			dude.set_running(true)
			dude.is_paused = false
			dude.set_process(true)
			dude.set_physics_process(true)
#			if dude.player_controlled == false:
#				dude.controller.reset_ai()


func _on_manager_spawn_timer_timeout() -> void:
	manager = SpawnManager.get_new_manager()
	add_child(manager)
	manager.initiate()
