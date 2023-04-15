extends Label

func update_data():
	var keys : Array = TargetTracker.targets.keys()
	var values : Array = TargetTracker.targets.values()
	text = ""
	
	for i in keys.size():
		text += str(keys[i].character_stats.Team) + " : " + str(values[i].character_stats.Team) + "\n"
