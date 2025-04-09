class_name ClassGravityComponent
extends Node

@export var wall_ray : RayCast2D
@export var gravity : float = 800.0
@export var wall_gravity : float = 100.0

var is_falling : bool = false

func handle_gravity(body : CharacterBody2D, delta : float) : 
	if not body.is_on_floor() and !wall_collision() : 
		body.velocity.y += gravity * delta
		
	elif wall_collision() and is_falling : 
			body.velocity.y += wall_gravity * delta
			
	elif wall_collision() and !is_falling : 
			body.velocity.y += gravity * delta

		
	is_falling = body.velocity.y > 0 and not body.is_on_floor()
	
func wall_collision() -> bool : 
	return wall_ray.is_colliding()
