class_name ClassAnimationComponent
extends Node

@export_group("Nodes")
@export var sprite : AnimatedSprite2D
@export var hurtbox_component : ClassHurtboxComponent

var is_hurt : bool = false

func _ready() -> void:
	hurtbox_component.hurt_animation.connect(handle_hurt_animation)

func facing_direction() -> float : 
	return 1 if sprite.flip_h else -1

func handle_flip_sprite(direction : float) -> void : 
	if direction == 0 :
		return 
	sprite.flip_h = false if direction > 0 else true

func handle_run_animation(x_velocity : float) : 
	if is_hurt : 
		return
	if x_velocity != 0 : 
		sprite.play("run")
	else : 
		sprite.play("idle")

func handle_jump_animation(is_jumping : bool, is_falling : bool) : 
	if is_hurt : 
		return
	if is_jumping :  
		sprite.play("jump") 
	elif is_falling : 
		sprite.play("fall")

func handle_slide_animation (is_sliding : bool, is_jumping : bool, is_falling : bool) : 
	if is_hurt : 
		return
	if is_jumping or is_falling : 
		return
	if is_sliding : 
		if sprite.animation != "slide" : 
			sprite.play("slide")
	else : 
		return
		
func handle_hurt_animation() : 
	if is_hurt : 
		return
	
	is_hurt = true
	sprite.stop()
	sprite.play("hurt")
	sprite.animation_finished.connect(on_hurt_animation_finished)

func on_hurt_animation_finished() : 
	is_hurt = false
	sprite.animation_finished.disconnect(on_hurt_animation_finished)
