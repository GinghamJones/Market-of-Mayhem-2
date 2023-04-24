class_name CharacterData
extends Resource

@export_enum("MEAT", "BAKERY", "CASHIER", "FLORAL", "FREIGHT", "KITCHEN", "PRODUCE") var Team: String
@export var max_health : int = 100
@export var single_fire : bool
var current_health : int
@export var base_damage : int = 10
@export var special_damage : int
@export var projectile_speed : float 
@export var projectile_damage : int
@export var max_ammo : int
var current_ammo : int

@export var move_speed : float = 5
@export var acceleration : float = 0.1
@export var gravity : float = 30
