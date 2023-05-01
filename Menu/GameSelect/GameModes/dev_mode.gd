class_name DevMode
extends GameMode


@onready var dev_menu : Control = $DevMenu


func _ready():
	super()
	dev_menu.hide()

func _unhandled_input(event):
	if event.is_action_pressed("DevMenu"):
		if dev_menu.visible == false:
			dev_menu.show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			check_available_classes()
		else:
			dev_menu.hide()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func score_changed():
	

func check_available_classes():
	# In theory, should check which character classes are full of players and disable button if so
	pass


func _on_butcher_button_pressed():
	add_character("Meat", false)

func _on_cook_button_pressed():
	add_character("Kitchen", false)

func _on_florist_button_pressed():
	add_character("Floral", false)

func _on_produce_button_pressed():
	add_character("Produce", false)

func _on_freight_button_pressed():
	add_character("Freight", false)

func _on_cashier_button_pressed():
	add_character("Cashier", false)

func _on_baker_button_pressed():
	add_character("Bakery", false)
