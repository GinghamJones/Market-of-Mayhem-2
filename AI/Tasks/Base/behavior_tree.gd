class_name BehaviorTree
extends Node

enum {
	SUCCESS,
	RUNNING,
	FAILURE
}

const NOT_RUNNING : int = -1
var children : Array
var running_child : int = NOT_RUNNING
