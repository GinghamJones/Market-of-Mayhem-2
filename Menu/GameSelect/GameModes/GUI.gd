extends Control

var scoreboard : Array = []


func _ready():
	$ScoreBoard.hide()


func score_changed(my_name : String, new_score : int):
	# This is a quick sketch. Could be more performant
	for node in scoreboard:
		if node.name == my_name:
			node.text = str(new_score)
			return


func populate_scoreboard(current_characters : Dictionary):
	scoreboard.clear()
	
	for key in current_characters.keys():
		if current_characters[key].size() < 1:
			pass
		var board_to_add_to = get_node("ScoreBoard/" + key + "/" + key + "Scores")
		
		# Delete previous score nodes if dev mode
		for child in board_to_add_to.get_children():
			child.queue_free()
			
		for i in current_characters[key].size():
			
			var current_character : Character = current_characters[key][i]
			
			var name_label : Label = Label.new()
			name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
#			get_node("GUI/ScoreBoard/" + team + "/" + team + "Scores")
			board_to_add_to.add_child(name_label)
			name_label.text = current_character.character_stats.my_name
			
			var score_label : Label = Label.new()
			score_label.name = current_character.character_stats.my_name
			score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			board_to_add_to.add_child(score_label)
			score_label.text = str(current_character.score)
			
			scoreboard.push_back(score_label)
