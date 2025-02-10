class_name ClassMovementComponent
extends Node

@export_subgroup("Settings")
@export var speed : float = 45

@export var ground_accel := 4
@export var ground_decel := 7
@export var air_accel := 10
@export var air_decel := 3

func handle_x_movement(body : CharacterBody2D, direction : float) -> void : 
	var velocity_change_speed : float
	
	if body.is_on_floor() : 
		velocity_change_speed = ground_accel if direction != 0 else ground_decel
	else : 
		velocity_change_speed = air_accel if direction != 0 else air_decel
		
	body.velocity.x = move_toward(body.velocity.x, direction * speed, velocity_change_speed)
