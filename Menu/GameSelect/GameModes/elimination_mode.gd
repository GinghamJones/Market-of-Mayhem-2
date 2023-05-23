extends GameMode

var teams_in_play : Dictionary = {}
@export var max_lives : int


func start_round() -> void:
	reset_teams_in_play()
	reset_characters()
	
	current_round += 1
	countdown_text.show()
	start_timer.start()
	
	await start_timer.timeout
	
	countdown_text.hide()


func reset_characters() -> void:
	for key in current_characters.keys():
		for dude in current_characters[key]:
			dude.should_respawn = true
			dude.lives_left = max_lives
			dude.respawn()


func reset_teams_in_play() -> void:
	teams_in_play = {
		"Meat" : 3,
		"Kitchen" : 3,
		"Floral" : 3,
		"Freight" : 3,
		"Cashier" : 3,
		"Produce" : 3,
		"Baker" : 3
	}
