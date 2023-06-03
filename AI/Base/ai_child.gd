class_name AIChild
extends Node

var controller : AIController
var detection_area : Area3D
var my_speed : int
var current_target : Character
var flee_target : Character

const MELEE = 0
const RANGED = 1

var current_mode : int = RANGED
