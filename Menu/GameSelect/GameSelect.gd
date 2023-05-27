extends Control

@onready var char_text : Label = $SelectText
var selected_char : String = "" : set = set_selected_char
# MAKE SURE TO CHANGE THIS BACK TO 'SHIT'!!!
var player_name : String = "dumbass"

signal change_scene


func set_selected_char(character : String) -> void:
	selected_char = character
	char_text.text = "Select Character : " + str(selected_char)


func _on_devmode_pressed():
	if selected_char == "":
		return
	emit_signal("change_scene", "DevMode", selected_char, player_name)


func _on_timed_mode_start_pressed():
	if selected_char == "":
		return
	if not check_for_name():
		return
	emit_signal("change_scene", "TimedMode", selected_char, player_name)


func _on_quit_button_pressed():
	get_tree().quit()


func _on_line_edit_text_submitted(new_text):
	player_name = new_text
	$VBoxContainer/LineEdit.editable = false


func _on_elimination_mode_start_pressed() -> void:
	if selected_char == "":
		return
	if not check_for_name():
		return
	change_scene.emit("EliminationMode", selected_char, player_name)


func check_for_name() -> bool:
	if player_name == "shit":
		$VBoxContainer/LineEdit.placeholder_text = "enter a name you dingus"
		return false
	
	return true


func _on_meat_button_pressed() -> void:
	selected_char = "Meat"


func _on_kitchen_button_pressed() -> void:
	selected_char = "Kitchen"


func _on_floral_button_pressed() -> void:
	selected_char = "Floral"


func _on_freight_button_pressed() -> void:
	selected_char = "Freight"


func _on_produce_button_pressed() -> void:
	selected_char = "Produce"


func _on_cashier_button_pressed() -> void:
	selected_char = "Cashier"


func _on_baker_button_pressed() -> void:
	selected_char = "Bakery"
