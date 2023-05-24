extends Control

var selected_char : String = ""
# MAKE SURE TO CHANGE THIS BACK TO 'SHIT'!!!
var player_name : String = "dumbass"

signal change_scene


func _on_character_select_item_selected(index):
	match index:
		0:
			selected_char = "Bakery"
		1:
			selected_char = "Cashier"
		2:
			selected_char = "Floral"
		3:
			selected_char = "Kitchen"
		4:
			selected_char = "Meat"
		5:
			selected_char = "Freight"
		6:
			selected_char = "Produce"


func _on_devmode_pressed():
	emit_signal("change_scene", "DevMode", selected_char, player_name)


func _on_timed_mode_start_pressed():
	if not check_for_name():
		return
	emit_signal("change_scene", "TimedMode", selected_char, player_name)


func _on_quit_button_pressed():
	get_tree().quit()


func _on_line_edit_text_submitted(new_text):
	player_name = new_text
	$VBoxContainer/LineEdit.editable = false


func _on_elimination_mode_start_pressed() -> void:
	if not check_for_name():
		return
	change_scene.emit("EliminationMode", selected_char, player_name)


func check_for_name() -> bool:
	if player_name == "shit":
		$VBoxContainer/LineEdit.placeholder_text = "enter a name you dingus"
		return false
	
	return true
