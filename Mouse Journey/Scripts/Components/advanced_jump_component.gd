class_name ClassAdvancedJumpComponent
extends Node

@export_group("Nodes") 
@export var jumpbuffer_timer : Timer
@export var coyote_timer : Timer

@export_group("Settings")
@export var jump_speed : float = -250.0


var is_going_up : bool = false
var is_jumping : bool
var last_frame_on_floor : bool

signal landed

func is_allowed_to_jump(body : CharacterBody2D, jump_button_pressed : bool) : 
	return jump_button_pressed and (body.is_on_floor() or not coyote_timer.is_stopped())
	
	
func handle_jump(body : CharacterBody2D, jump_button_pressed : bool, jump_released : bool) : 
	
	if has_just_landed(body) : 
		landed.emit()
		
	if has_just_landed_after_jump(body) : 
		is_jumping = false
	
	if is_allowed_to_jump(body, jump_button_pressed) :  
		jump(body)
	
	handle_coyote_time(body)
	handle_jump_buffer(body, jump_button_pressed)
	handle_variable_jump_height(body, jump_released)
	
	is_going_up = body.velocity.y < 0 and not body.is_on_floor()
	
	last_frame_on_floor = body.is_on_floor()

func has_just_landed_after_jump(body : CharacterBody2D) -> bool : 
	return body.is_on_floor() and not last_frame_on_floor and is_jumping

func has_just_landed(body : CharacterBody2D) -> bool : 
	return body.is_on_floor() and not last_frame_on_floor
	
func has_just_stepped_off_a_ledge(body : CharacterBody2D) : 
	return not body.is_on_floor() and last_frame_on_floor and not is_jumping 

func handle_coyote_time(body : CharacterBody2D) :
	if has_just_stepped_off_a_ledge(body) : 
		coyote_timer.start()
	
	if not coyote_timer.is_stopped() and not is_jumping : 
		body.velocity.y = 0
	

func handle_jump_buffer(body : CharacterBody2D, jump_button_pressed) : 
	if jump_button_pressed and not body.is_on_floor() : 
		jumpbuffer_timer.start()
	
	if body.is_on_floor() and not jumpbuffer_timer.is_stopped(): 
		jump(body)

func handle_variable_jump_height(body : CharacterBody2D, jump_released : bool) : 
	if jump_released and is_going_up : 
		body.velocity.y = 0

func jump(body : CharacterBody2D) : 
	if body.is_on_floor() : 
		body.velocity.y = jump_speed
		jumpbuffer_timer.stop()
		coyote_timer.stop()
		is_jumping = true
		

	
		
