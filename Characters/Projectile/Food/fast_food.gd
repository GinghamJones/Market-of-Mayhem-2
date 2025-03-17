extends Projectile


func _ready():
	var food_pieces = $FoodPieces.get_children()
	var random_food : int = randi_range(0, $FoodPieces.get_child_count() - 1)
	food_pieces[random_food].visible = true
