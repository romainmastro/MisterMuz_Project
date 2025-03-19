class_name GlidingComponent
extends Node

@export var gliding_factor : float = 1.3
var is_gliding : bool = false

func handle_gliding(body : CharacterBody2D, glide_button_pressed : bool) :
	if body.is_on_floor() : 
		is_gliding = false
		return
	if not GlobalPlayerStats.has_snow_hat : 
		return
	if not glide_button_pressed : 
		is_gliding = false
		return
	if glide_button_pressed : 
		is_gliding = true
		glide(body)
	
func glide(body : CharacterBody2D) : 
	var real_velocity = body.get_real_velocity()
	if real_velocity.y < 0 : 
		return
	
	body.velocity.y = body.velocity.y / gliding_factor
