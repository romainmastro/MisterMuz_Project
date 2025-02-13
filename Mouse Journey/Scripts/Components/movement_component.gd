class_name ClassMovementComponent
extends Node

@export_subgroup("Settings")
@export var running_speed : float = 45

@export var ground_accel := 4
@export var ground_decel := 7
@export var air_accel := 10
@export var air_decel := 3

var floor_angle : float = 0
var speed : float = 0

func handle_x_movement(body : CharacterBody2D, direction : float) -> void : 
	var velocity_change_speed : float
	if body.is_on_floor() : 
		velocity_change_speed = ground_accel if direction != 0 else ground_decel
	else : 
		velocity_change_speed = air_accel if direction != 0 else air_decel

	body.velocity.x = move_toward(body.velocity.x, direction * running_speed, velocity_change_speed)

	
