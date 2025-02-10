class_name ClassAnimationComponent
extends Node

@export_group("Nodes")
@export var sprite : AnimatedSprite2D

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
