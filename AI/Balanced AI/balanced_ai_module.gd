class_name AIModule
extends Node

@onready var controller : AIController = get_parent()
@onready var detection_field : Area3D = controller.detection_area

var just_punched : bool = false
var too_many_dudes : bool = false
