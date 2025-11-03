extends CanvasLayer


var tracked_char : Character :
	set(char):
		tracked_char = char
		tracked_char_controller = char.controller
var tracked_char_controller : AIController2
@onready var chase: Label = $VBoxContainer/Chase
@onready var wander: Label = $VBoxContainer/Wander
@onready var punch: Label = $VBoxContainer/Punch
@onready var dodge: Label = $VBoxContainer/Dodge
@onready var fire: Label = $VBoxContainer/Fire
@onready var retreat: Label = $VBoxContainer/Retreat


func _physics_process(delta: float) -> void:
	if not tracked_char:
		return
	var action_scores := tracked_char_controller.actions.action_scores
	for action : String in action_scores:
		if action == "chase":
			chase.text = "chase: " + str(action_scores[action])
		elif action == "wander":
			wander.text = "wander: " + str(action_scores[action])
		elif action == "punch":
			punch.text = "punch: " + str(action_scores[action])
		elif action == "dodge":
			dodge.text = "dodge: " + str(action_scores[action])
		elif action == "fire":
			fire.text = "fire: " + str(action_scores[action])
		elif action == "retreat":
			retreat.text = "retreat: " + str(action_scores[action])
