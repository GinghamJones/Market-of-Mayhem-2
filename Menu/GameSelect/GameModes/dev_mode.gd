class_name DevMode
extends GameMode


@onready var dev_menu : Control = $DevMenu
@onready var start_round_timer : Timer = $Timers/StartRoundTimer
@onready var knife : PackedScene = preload("res://Projectile/Knife/knife.tscn")
@onready var food : PackedScene = preload("res://Projectile/Food/fast_food.tscn")
@onready var vase : PackedScene = preload("res://Projectile/Vase/vase.tscn")
@onready var coin : PackedScene = preload("res://Projectile/Coin/coin.tscn")

signal character_spawned


func _ready():
	character_spawned.connect(Callable(self, "_on_character_spawned"))
	super()
	call_deferred("add_character", player_character_type, true, player_name)
	await get_tree().physics_frame
	character_spawned.emit()
	dev_menu.hide()
	max_rounds = 10090
	await get_tree().physics_frame
	for key in current_characters.keys():
		for dude in current_characters[key]:
			dude.is_paused = false


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

##	get_tree().paused = true
#	current_round += 1
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
	character_spawned.emit()

func _on_cook_button_pressed():
	add_character("Kitchen", false)
	$GUI.populate_scoreboard(current_characters)
	character_spawned.emit()

func _on_florist_button_pressed():
	add_character("Floral", false)
	$GUI.populate_scoreboard(current_characters)
	character_spawned.emit()

func _on_produce_button_pressed():
	add_character("Produce", false)
	$GUI.populate_scoreboard(current_characters)
	character_spawned.emit()

func _on_freight_button_pressed():
	add_character("Freight", false)
	$GUI.populate_scoreboard(current_characters)
	character_spawned.emit()

func _on_cashier_button_pressed():
	add_character("Cashier", false)
	$GUI.populate_scoreboard(current_characters)
	character_spawned.emit()

func _on_baker_button_pressed():
	add_character("Bakery", false)
	$GUI.populate_scoreboard(current_characters)
	character_spawned.emit()

func _on_manager_pressed():
	manager = SpawnManager.get_new_manager()
	add_child(manager)
	manager.initiate()


func _on_button_pressed() -> void:
	for i in 100:
		var c = coin.instantiate()
		add_child(c)
		i /= 4
		c.global_position = Vector3(i, i, i)
		c.initiate(10, 10, get_tree().get_first_node_in_group("Character"))
	
	for i in 100:
		var v = vase.instantiate()
		add_child(v)
		i /= 4
		v.global_position = Vector3(i, i, i)
		v.initiate(10, 10, get_tree().get_first_node_in_group("Character"))

	for i in 100:
		var k = knife.instantiate()
		add_child(k)
		i /= 4
		k.global_position = Vector3(i, i, i)
		k.initiate(10, 10, get_tree().get_first_node_in_group("Character"))
		
	for i in 100:
		var f = food.instantiate()
		add_child(f)
		i /= 4
		f.global_position = Vector3(i, i, i)
		f.initiate(10, 10, get_tree().get_first_node_in_group("Character"))


func _on_character_spawned() -> void:
#	await get_tree().physics_frame
	for key in current_characters.keys():
		for character in current_characters[key]:
			character.character_stats.current_ammo = 1000
			character.is_paused = false
			character.set_process(true)
			character.set_physics_process(true)
