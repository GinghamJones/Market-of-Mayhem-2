class_name DevMode
extends GameMode


@onready var dev_menu : Control = $DevMenu
@onready var start_round_timer : Timer = $Timers/StartRoundTimer


func _ready():
	super()
	call_deferred("add_character", player_character_type, true, player_name)
	dev_menu.hide()
	max_rounds = 10090


func _unhandled_input(event):
	if event.is_action_pressed("DevMenu"):
		if dev_menu.visible == false:
			dev_menu.show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			check_available_classes()
		else:
			dev_menu.hide()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("StartRound"):
		start_round()
	if event.is_action_pressed("EndRound"):
		end_round()


func start_round(): 
	for key in current_characters.keys():
		for dude in current_characters[key]:
			dude.respawn()
			dude.is_paused = true
			dude.should_respawn = true
			await dude.respawn_complete
	
#	get_tree().paused = true
	current_round += 1
	countdown_text.show()
	start_timer.start()
	await start_timer.timeout
	countdown_text.hide()
	for key in current_characters.keys():
		for dude in current_characters[key]:
			dude.is_paused = false
#	get_tree().paused = false
#	round_timer.start()


func end_round():
	# Need to figure out how to move players into place before game is paused
	if current_round < max_rounds:
		scoreboard.show()
		for key in current_characters.keys():
			for dude in current_characters[key]:
				dude.should_respawn = false
				dude.die()
		intermission_timer.start()
		await intermission_timer.timeout
		scoreboard.hide()

		start_round()


func check_available_classes():
	# In theory, should check which character classes are full of players and disable button if so
	pass


func _on_butcher_button_pressed():
	add_character("Meat", false)
	$GUI.populate_scoreboard(current_characters)

func _on_cook_button_pressed():
	add_character("Kitchen", false)
	$GUI.populate_scoreboard(current_characters)

func _on_florist_button_pressed():
	add_character("Floral", false)
	$GUI.populate_scoreboard(current_characters)

func _on_produce_button_pressed():
	add_character("Produce", false)
	$GUI.populate_scoreboard(current_characters)

func _on_freight_button_pressed():
	add_character("Freight", false)
	$GUI.populate_scoreboard(current_characters)

func _on_cashier_button_pressed():
	add_character("Cashier", false)
	$GUI.populate_scoreboard(current_characters)

func _on_baker_button_pressed():
	add_character("Bakery", false)
	$GUI.populate_scoreboard(current_characters)

func _on_manager_pressed():
	manager = SpawnManager.get_new_manager()
	add_child(manager)
	manager.initiate()
