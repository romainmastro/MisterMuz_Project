class_name ClassAnimationComponent
extends Node

@export_group("Nodes")
@export var sprite : AnimatedSprite2D

func facing_direction() -> float : 
	return 1 if sprite.flip_h else -1

func handle_flip_sprite(direction : float) -> void : 
	if direction == 0 :
		return 
	sprite.flip_h = false if direction > 0 else true

func handle_run_animation(x_velocity : float) : 
	if x_velocity != 0 : 
		sprite.play("run")
	else : 
		sprite.play("idle")

func handle_jump_animation(is_jumping : bool, is_falling : bool) : 
	if is_jumping :  
		sprite.play("jump") 
	elif is_falling : 
		sprite.play("fall")

func handle_slide_animation (body : CharacterBody2D, is_sliding : bool, is_jumping : bool, is_falling : bool) : 
	#var floor_normal = body.get_floor_normal()
	#var tangent = Vector2(-floor_normal.y, floor_normal.x)
	if is_jumping or is_falling : 
		return
		
	if is_sliding : 
		if sprite.animation != "slide" : 
			sprite.play("slide")
	else : 
		return
		
