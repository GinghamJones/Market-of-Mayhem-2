class_name TimedMode
extends GameMode


@onready var round_timer : Timer = $Timers/RoundTimer
@onready var start_timer : Timer = $Timers/StartRoundTimer
@onready var intermission_timer : Timer = $Timers/IntermissionTimer

var current_round : int = 0

# Store scores in arrays for each team. Each array holds individual score of each player on team. 
var score : Dictionary = {
	"Bakery" : [],
	"Meat" : [],
	"Kitchen" : [],
	"Produce" : [],
	"Floral" : [],
	"Freight" : [],
	"Cashier" : [],
}
