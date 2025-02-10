class_name ClassJumpComponent
extends Node

@export_group("Settings")
@export var jump_speed : float = -250.0

var is_jumping : bool = false

func handle_jump(body : CharacterBody2D, want_to_jump : bool) : 
	if want_to_jump and body.is_on_floor() : 
		body.velocity.y = jump_speed

	is_jumping = body.velocity.y < 0 and not body.is_on_floor()
