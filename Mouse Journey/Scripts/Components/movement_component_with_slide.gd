class_name ClassMovement_SlideComponent
extends Node

@export_subgroup("Settings")
@export var running_speed : float = 45
@export var sliding_speed : float = 450

@export var sliding_accel : float = 5.0
@export var sliding_decel : float = 2.0

@export var ground_accel : float = 4.0 # good values but not used
@export var ground_decel : float = 7.0 # good values but not used
@export var air_accel : float = 10.0
@export var air_decel : float = 3.0

# NOT has boots_gloves : 
@export var ice_ground_accel : float = 0.7
@export var ice_ground_decel : float = 0.7

# has boots_gloves : 
@export var boots_ground_accel : float = 4
@export var boots_ground_decel : float = 4

var can_slide : bool = false
var is_sliding : bool = false

func _ready() -> void:
	GlobalPlayerStats.has_boots_gloves_signal.connect(update_accel_decel)

func init_movement_component() : 
	if not GlobalPlayerStats.has_boots_gloves : 
		ground_accel = ice_ground_accel
		ground_decel = ice_ground_decel

func handle_x_movement(body : CharacterBody2D, direction : float, slide_button_pressed : bool) -> void : 
	var velocity_change_speed : float
	var speed : float 
	
	if body.is_on_floor() : 
		want_to_slide(body, slide_button_pressed, direction)
		if is_sliding : 
			velocity_change_speed = sliding_accel if direction != 0 else sliding_decel
		else : 
			velocity_change_speed = ground_accel if direction != 0 else ground_decel
	else : # Body is in the air
		can_slide = false
		is_sliding = false
		velocity_change_speed = air_accel if direction != 0 else air_decel
	
	speed = sliding_speed if can_slide else running_speed
	

	body.velocity.x = move_toward(body.velocity.x, direction * speed, velocity_change_speed)
	clamp(body.velocity.x, -body.velocity.x, sliding_speed)
	
	
func is_on_downward_slope(body: CharacterBody2D, direction : float) -> bool:
	if not body.is_on_floor() or direction == 0 :
		return false
		
	var floor_normal = body.get_floor_normal()
	
	# A negative floor_angle means the floor is angled downward relative to the up vector.
	if abs(floor_normal.x) < 0.1 :
		return false
	
	# player is on floor and the direction of the slope is the same as player so positive
	return floor_normal.x * direction > 0
	
func want_to_slide(body : CharacterBody2D, slide_button_pressed : bool, direction : float) : 
	can_slide = slide_button_pressed and is_on_downward_slope(body, direction) 
	is_sliding = can_slide and body.is_on_floor()
	
func update_accel_decel() : 
	ground_accel = boots_ground_accel
	ground_decel = boots_ground_decel
