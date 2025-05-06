extends Node2D


@export_group("Nodes")
@export var snow_mole_anim_sprite : AnimatedSprite2D
@export var snow_mole : CharacterBody2D
@export var SNOWMOUNDS : Array[Sprite2D]
@export var raycast_right : RayCast2D
@export var raycast_left : RayCast2D
@export var go_underground_timer : Timer
@export var travel_timer : Timer
@export var jumping_cooldown : Timer
@export var snow_puff_particles : CPUParticles2D

@export_group("Paramètres")
@export_enum("IDLE", "GO_UNDER", "JUMPING", "FALLING", "HIDING") var current_state = "IDLE"
@export var jump_force : float = -200.0
@export var snow_mole_offset : int = 3
@export var gravity : float = 600
@export var jumping_force = -200
@export var max_jumps : int 
var jump_counts : int = 0
var is_mound_1 : bool = true

var normal_scale : float = 1.0
var jumping_falling_scale : float = 1.5

@onready var debug_state: Label = $SnowMole/Control/debug_state


func _ready() -> void:
	switch_mounds()
	start_idle()
	
	max_jumps = randi_range(1, 3)
	

func _physics_process(delta: float) -> void:
	# apply gravity
	snow_mole.velocity.y += gravity * delta
	
	#switch_sprite_scale()
	
	if snow_mole.is_on_floor() : 
		
		flip_sprite()
		
		
		
		match current_state : 
			"IDLE" : 
				# animation
				start_idle()
				# timer for launching go_under and switch mounds
				if go_underground_timer.is_stopped() : 
					go_underground_timer.start()
				
				# transitions
				if should_jump() : 
					snow_mole.velocity.y = jumping_force
					jump_counts += 1
					current_state = "JUMPING"
				
				elif jump_counts >= max_jumps : 
					
					go_underground_timer.stop()
					jump_counts = 0
					max_jumps = randi_range(1, 3)
					_on_go_underground_timer_timeout()
				
			"GO_UNDER" : 
				# wait for travel_timer timeout
				pass
				
			"FALLING" : 
				snow_puff_particles.emitting = true
				if jumping_cooldown.is_stopped() : 
					jumping_cooldown.start()
					current_state = "IDLE"
			
	else : # in the air
		match current_state : 
			"JUMPING" : 
				snow_puff_particles.emitting = true
				# animation
				if snow_mole.velocity.y < 0 : 
					snow_mole_anim_sprite.play("jump")
				
				# transition 
				if snow_mole.velocity.y >= 0 : 
					current_state = "FALLING"
			"FALLING" : 
				# animation
				snow_mole_anim_sprite.play("fall")
				
	
	snow_mole.move_and_slide()
	
	get_debug_state()
	
func start_idle() : 
	snow_mole_anim_sprite.play("idle")

func switch_mounds() : 
	
	SNOWMOUNDS.shuffle()
	var random_mound = SNOWMOUNDS[0]
	snow_mole.global_position.x = random_mound.global_position.x
	snow_mole.global_position.y = random_mound.global_position.y - snow_mole_offset
	
	snow_puff_particles.global_position = Vector2(random_mound.global_position.x,random_mound.global_position.y + snow_mole_offset)
	
	#if is_mound_1 : 
		#snow_mole.global_position.x = SNOWMOUNDS[1].global_position.x
		#snow_mole.global_position.y = SNOWMOUNDS[1].global_position.y - snow_mole_offset
		#is_mound_1 = false
		#
	#else : 
		#snow_mole.global_position.x = SNOWMOUNDS[0].global_position.x
		#snow_mole.global_position.y = SNOWMOUNDS[0].global_position.y - snow_mole_offset
		#is_mound_1 = true

func _on_go_underground_timer_timeout() -> void:
	current_state = "GO_UNDER"
	# animation
	snow_mole_anim_sprite.play("go_under")
	
	if travel_timer.is_stopped() : 
		travel_timer.start()

func _on_travel_timer_timeout() -> void:
	switch_mounds()
	start_idle()
	current_state = "IDLE"

func flip_sprite() : 
	if is_player_detected() == "player_is_left" :
		snow_mole_anim_sprite.flip_h = true
	elif is_player_detected() == "player_is_right" :
		snow_mole_anim_sprite.flip_h = false

func is_player_detected() : 
	if (raycast_left.is_colliding()) and (raycast_left.get_collider() is PlayerClass) : 
		return "player_is_left"
	elif (raycast_right.is_colliding()) and (raycast_right.get_collider() is PlayerClass) :
		return "player_is_right"
	else : 
		return "cant_see_player" 

#func _on_animated_sprite_2d_animation_finished() -> void:
	#if snow_mole_anim_sprite.animation == "fall" : 
		#current_state = "IDLE"

func should_jump() -> bool : 
	return (
		(jumping_cooldown.is_stopped()) and 
		(jump_counts < max_jumps) and 
		(is_player_detected() == "player_is_left" or 
		is_player_detected() == "player_is_right"
		)
	)

func switch_sprite_scale() : 
	match current_state : 
		"JUMPING", "FALLING" : 
			snow_mole_anim_sprite.scale = Vector2(1.2, 1.2)
		_ : 
			snow_mole_anim_sprite.scale = Vector2(1, 1)
######################"" DEBUG ############################
func get_debug_state() : 
	debug_state.text = current_state
