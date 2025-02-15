class_name ClassMovement_SlideComponent
extends Node

@export_subgroup("Settings")
@export var running_speed : float = 45
@export var sliding_speed : float = 90

@export var ground_accel := 4
@export var ground_decel := 7
@export var air_accel := 10
@export var air_decel := 3


var can_slide : bool = false
var is_sliding : bool = false

func handle_x_movement(body : CharacterBody2D, direction : float, slide_button_pressed : bool) -> void : 
	var velocity_change_speed : float
	var speed : float 
	
	if body.is_on_floor() : 
		want_to_slide(body, slide_button_pressed, direction)
		velocity_change_speed = ground_accel if direction != 0 else ground_decel
	else : 
		velocity_change_speed = air_accel if direction != 0 else air_decel
	
	speed = sliding_speed if can_slide else running_speed
		
	body.velocity.x = move_toward(body.velocity.x, direction * speed, velocity_change_speed)

func is_on_downward_slope(body: CharacterBody2D, direction : float) -> bool:
	if not body.is_on_floor() or direction == 0 :
		return false
		
	var floor_normal = body.get_floor_normal()
	
	# A negative floor_angle means the floor is angled downward relative to the up vector.
	if abs(floor_normal.x) < 0.1:
		return false
	
	# player is on floor and the direction of the slope is the same as player so positive
	return floor_normal.x * direction > 0
	
func want_to_slide(body : CharacterBody2D, slide_button_pressed : bool, direction : float) : 
	can_slide = slide_button_pressed and is_on_downward_slope(body, direction) 
	is_sliding = can_slide and body.is_on_floor()
	
