class_name ClassInputComponent
extends Node

var x_input : float = 0.0


func _process(_delta: float) -> void:
	x_input = Input.get_axis("move_left", "move_right")
	
func get_jump_input() -> bool : 
	return Input.is_action_just_pressed("jump")

func get_jump_released_input() -> bool : 
	return Input.is_action_just_released("jump")

func get_slide_input() -> bool : 
	return Input.is_action_pressed("slide")
