class_name Freight
extends Character
@onready var lazer_tree = $Lazer


func _ready():
	super()
	lazer_tree.connect("colliding", Callable(self, "deal_lazer_damage"))


func _handle_firing():
	lazer_tree.activate(0.3)


func stop_firing():
	lazer_tree.deactivate(0.3)


func deal_lazer_damage(enemy : Character):
	if enemy.character_stats.Team != "Freight":
		enemy.take_projectile_damage(character_stats.projectile_damage, null, self)
