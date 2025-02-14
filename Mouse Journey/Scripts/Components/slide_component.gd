class_name ClassSlideComponent
extends Node

@export_group("Settings")
@export var sliding_speed_multiplier : float = 1.7

func is_on_a_downward_slope(body : CharacterBody2D) : 
	return body.is_on_floor() and body.get_real_velocity().y > 0.1

func handle_slide(body : CharacterBody2D, slide_button_pressed : bool) : 
	if is_on_a_downward_slope(body) and slide_button_pressed : 
		slide(body)

func slide(body : CharacterBody2D) : 
	body.velocity = body.velocity.rotated(body.get_floor_angle())
	body.velocity.x *= sliding_speed_multiplier
