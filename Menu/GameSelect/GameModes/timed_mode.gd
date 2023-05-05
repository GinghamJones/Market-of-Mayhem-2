class_name TimedMode
extends GameMode


@onready var round_timer : Timer = $Timers/RoundTimer



func _ready():
	super()
#	call_deferred("spawn_bots")
	await get_tree().process_frame
	spawn_bots()
	await get_tree().process_frame
	$GUI.populate_scoreboard(current_characters)
	get_tree().paused = true
	start_round()
	

func start_round(): 
	for key in current_characters.keys():
		for dude in current_characters[key]:
			dude.respawn

			dude.is_respawning = true
	current_round += 1
	countdown_text.show()
	start_timer.start()
	await start_timer.timeout
	countdown_text.hide()
	get_tree().paused = false
	round_timer.start()


func end_round():
	if current_round < max_rounds:
		$GUI/ScoreBoard.show()
		for key in current_characters.keys():
			for dude in current_characters[key]:
				dude.is_respawning = false
				dude.die()
		intermission_timer.start()
		await intermission_timer.timeout
		start_round()
	
	else:
		$GUI/ScoreBoard.show()
		intermission_timer.start()
		await intermission_timer.timeout
		SceneLoader.load_character_select()


func spawn_bots():
	var teams : Array = ["Bakery", "Floral", "Meat", "Cashier", "Kitchen", "Produce", "Freight",]
	
	for t in teams:
		for i in 3:
			add_character(t, false)


func _input(event):
	if event.is_action_pressed("ShowScoreboard"):
		$GUI/ScoreBoard.show()
	if event.is_action_released("ShowScoreboard"):
		$GUI/ScoreBoard.hide()
