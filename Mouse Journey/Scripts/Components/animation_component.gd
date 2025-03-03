class_name ClassAnimationComponent
extends Node

@export_group("Nodes")
@export var player_sprite : AnimatedSprite2D
@export var boots_gloves_sprite : AnimatedSprite2D
@export var snowsuit_sprite : AnimatedSprite2D
@export var snowHat_sprite : AnimatedSprite2D
@export var muffler_sprite : AnimatedSprite2D

@export var hurtbox_component : ClassHurtboxComponent

var is_hurt : bool = false

func _ready() -> void:
	boots_gloves_sprite.visible = GlobalPlayerStats.has_boots_gloves_suit
	snowsuit_sprite.visible = GlobalPlayerStats.has_boots_gloves_suit
	snowHat_sprite.visible = GlobalPlayerStats.has_snow_hat
	muffler_sprite.visible = GlobalPlayerStats.has_muffler
	
	hurtbox_component.hurt_animation.connect(handle_hurt_animation)
	GlobalPlayerStats.has_boots_gloves_suit_signal.connect(update_boots_gloves_visibility)
	GlobalPlayerStats.has_snowHat_signal.connect(update_snowHat_visibility)
	GlobalPlayerStats.has_muffler_signal.connect(update_muffler_visibility)
	
func facing_direction() -> float : 
	return 1 if player_sprite.flip_h else -1

func handle_flip_sprite(direction : float) -> void : 
	if direction == 0 :
		return 
	#player_sprite.flip_h = false if direction > 0 else true
	if direction > 0 : 
		player_sprite.flip_h = false
		boots_gloves_sprite.flip_h = false
		snowsuit_sprite.flip_h = false
		snowHat_sprite.flip_h = false
		muffler_sprite.flip_h = false
	else : 
		player_sprite.flip_h = true
		boots_gloves_sprite.flip_h = true
		snowsuit_sprite.flip_h = true
		snowHat_sprite.flip_h = true
		muffler_sprite.flip_h = true

func handle_run_animation(x_velocity : float) : 
	if is_hurt : 
		return
	if x_velocity != 0 : 
		player_sprite.play("run")
		boots_gloves_sprite.play("run")
		snowsuit_sprite.play("run")
		snowHat_sprite.play("run")
		muffler_sprite.play("run")
	else : 
		player_sprite.play("idle")
		boots_gloves_sprite.play("idle")
		snowsuit_sprite.play("idle")
		snowHat_sprite.play("idle")
		muffler_sprite.play("idle")

func handle_jump_animation(is_jumping : bool, is_falling : bool) : 
	if is_hurt : 
		return
	if is_jumping :  
		player_sprite.play("jump") 
		boots_gloves_sprite.play("jump")
		snowsuit_sprite.play("jump")
		snowHat_sprite.play("jump")
		muffler_sprite.play("jump")
	elif is_falling : 
		player_sprite.play("fall")
		boots_gloves_sprite.play("fall")
		snowsuit_sprite.play("fall")
		snowHat_sprite.play("fall")
		muffler_sprite.play("fall")

func handle_slide_animation (is_sliding : bool, is_jumping : bool, is_falling : bool) : 
	if is_hurt : 
		return
	if is_jumping or is_falling : 
		return
	if is_sliding : 
		if player_sprite.animation != "slide" : 
			player_sprite.play("slide")
			boots_gloves_sprite.play("slide")
			snowsuit_sprite.play("slide")
			snowHat_sprite.play("slide")
			muffler_sprite.play("slide")
	else : 
		return
		
func handle_hurt_animation() : 
	if is_hurt : 
		return
	
	is_hurt = true
	player_sprite.stop()
	player_sprite.play("hurt")
	boots_gloves_sprite.play("hurt")
	snowsuit_sprite.play("hurt")
	snowHat_sprite.play("hurt")
	muffler_sprite.play("hurt")
	
	player_sprite.animation_finished.connect(on_hurt_animation_finished)
	boots_gloves_sprite.animation_finished.connect(on_hurt_animation_finished)
	snowsuit_sprite.animation_finished.connect(on_hurt_animation_finished)
	muffler_sprite.animation_finished.connect(on_hurt_animation_finished)

func on_hurt_animation_finished() : 
	is_hurt = false
	
	player_sprite.animation_finished.disconnect(on_hurt_animation_finished)
	boots_gloves_sprite.animation_finished.disconnect(on_hurt_animation_finished)
	snowsuit_sprite.animation_finished.disconnect(on_hurt_animation_finished)
	muffler_sprite.animation_finished.disconnect(on_hurt_animation_finished)

func update_boots_gloves_visibility() : 
	boots_gloves_sprite.visible = true
	snowsuit_sprite.visible = true

func update_snowHat_visibility() : 
	snowHat_sprite.visible = true
	
func update_muffler_visibility() : 
	muffler_sprite.visible = true
