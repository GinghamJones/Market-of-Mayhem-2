extends GameMode

var teams_in_play : Dictionary = {}
@export var max_lives : int


func _ready() -> void:
	super()
	await get_tree().process_frame
	spawn_players()
	await get_tree().process_frame
	for key in current_characters.keys():
		for dude in current_characters[key]:
			dude.i_died.connect(Callable(self, "character_died"))
			dude.im_done_fer.connect(Callable(self, "character_done_fer"))
	$GUI.populate_scoreboard(current_characters)
	start_round()


func start_round() -> void:
	reset_teams_in_play()
	reset_characters()
	
	current_round += 1
	countdown_text.show()
	start_timer.start()
	
	await start_timer.timeout
	
	countdown_text.hide()
	unpause_characters()


func end_round() -> void:
	pause_characters()
	intermission_timer.start()
	scoreboard.show()
	announce_winner()
	await intermission_timer.timeout
	
	if current_round == 2:
		end_game()
	else:
		start_round()


func character_done_fer(team : String) -> void:
	teams_in_play[team] -= 1
	if teams_in_play[team] <= 0:
		teams_in_play.erase(team)
		check_teams_in_play()


func character_died(deceased : Character) -> void:
	deceased.set_lives_left(deceased.lives_left - 1)
	if deceased.lives_left == 0:
		deceased.should_respawn = false
		var team : String = deceased.get_team()
		teams_in_play[team] -= 1
		if teams_in_play[team] == 0:
			teams_in_play.erase(team)
			check_teams_in_play()


func check_teams_in_play() -> void:
	var teams_left : int = 7
	for key in teams_in_play.keys():
		if teams_in_play[key] == 0:
			teams_left -= 1
	
	if teams_left == 1:
		end_round()


func end_game() -> void:
	pass


func announce_winner() -> void:
	pass


func pause_characters() -> void:
	for key in current_characters.keys():
		for dude in current_characters[key]:
			dude.is_paused = true


func unpause_characters() -> void:
	for key in current_characters.keys():
		for dude in current_characters[key]:
			dude.is_paused = false


func reset_characters() -> void:
	for key in current_characters.keys():
		for dude in current_characters[key]:
			dude.should_respawn = true
			dude.set_lives_left(3)
			dude.respawn()


func spawn_players():
	var teams : Array = ["Bakery", "Floral", "Meat", "Cashier", "Kitchen", "Produce", "Freight",]
	
	add_character(player_character_type, true, player_name)
	
	for t in teams:
		var chars_to_spawn : int = 3
		if player_character_type ==t:
			chars_to_spawn = 2
			
		for i in chars_to_spawn:
			add_character(t, false)
	
	pause_characters()
#	reset_characters()


func reset_teams_in_play() -> void:
	teams_in_play = {
		"Meat" : 3,
		"Kitchen" : 3,
		"Floral" : 3,
		"Freight" : 3,
		"Cashier" : 3,
		"Produce" : 3,
		"Bakery" : 3
	}
