class_name CharacterData
extends Resource

@export_enum("Meat", "Bakery", "Cashier", "Floral", "Freight", "Kitchen", "Produce", "Manager", "Customer") var Team: String
var my_name : String = ""

@export var max_health : int = 100
var current_health : int

@export var single_fire : bool

@export var base_damage : int = 10
@export var special_damage : int

@export var projectile_damage : int
@export var projectile_speed : float 
@export var max_ammo : int
var current_ammo : int

@export var move_speed : float = 5
@export var acceleration : float = 10
@export var gravity : float = 30
@export var dodge_force : float = 7.5
@export var punch_force : float = 5
