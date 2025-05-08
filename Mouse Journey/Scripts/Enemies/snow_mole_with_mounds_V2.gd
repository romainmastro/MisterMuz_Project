extends Node2D

@export var snow_mole : CharacterBody2D
@export var snow_mole_anim_sprite : AnimatedSprite2D
@export var MOUNDS : Array[Sprite2D]
var current_mound_index : int = 0
@export var switch_mound_timer : Timer
@export var underground_timer : Timer
@export var attacking_cooldown : Timer
@export var ray_right : RayCast2D
@export var ray_left : RayCast2D

@onready var debug_state: Label = $snow_mole/Control/Label


@export_enum("IDLING", "SWITCHING_MOUND","TRAVELING_UNDERGROUND", "ATTACKING", "DEAD") var current_state = "IDLING"
@export var gravity : float = 600.0
@export var hop_force : float = -80.0
@export var attacking_force : float = -200.0
var hop_initiated : bool = false
var has_left_floor : bool = false
var has_attacked_once : bool = false
var has_left_floor_to_attack : bool = false

var snow_mole_scale : Vector2 = Vector2(0.8, 0.8)

func _ready() -> void:
	start_idle()
	snow_mole.global_position = MOUNDS[0].global_position 
	snow_mole.scale = snow_mole_scale

func _physics_process(delta: float) -> void:
	
	apply_gravity(delta)
	
	flip_snow_mole()
	
	match current_state : 
		
		"IDLING" : 
			hop_initiated = false
			has_left_floor = false
			
			
			#animation
			start_idle()
			
			if attacking_cooldown.is_stopped() and switch_mound_timer.is_stopped() : 
				switch_mound_timer.start()
				
			# transition
			if is_player_detected() and attacking_cooldown.is_stopped() : 
				switch_mound_timer.stop()
				# transition
				current_state = "ATTACKING"
		
		"SWITCHING_MOUND" :
			if not hop_initiated:
				snow_mole_anim_sprite.stop()
				snow_mole.velocity.y = hop_force
				hop_initiated = true
			
			if hop_initiated and not snow_mole.is_on_floor() : 
				has_left_floor = true
			
			# transition
			if snow_mole.is_on_floor() and has_left_floor : 
				snow_mole.visible = false
				current_state = "TRAVELING_UNDERGROUND"
				underground_timer.start()
				
		"TRAVELING_UNDERGROUND" : 
			# Do nothing : just wait for underground_timer to timeout
			pass
		
		"ATTACKING" : 
			if not has_attacked_once : 
				snow_mole.velocity.y = attacking_force
				has_attacked_once = true
			# animation
				snow_mole_anim_sprite.play("attack")
			if has_attacked_once and not snow_mole.is_on_floor() : 
				has_left_floor_to_attack = true
			# transition
			if has_left_floor_to_attack and snow_mole.is_on_floor() : 
				attacking_cooldown.start()
				current_state = "IDLING"
	
	
	
	snow_mole.move_and_slide()
	
	
	get_debug_state()
	
func apply_gravity(delta : float) : 
	snow_mole.velocity.y += gravity * delta

func switch_mounds() : 
	current_mound_index = (current_mound_index + 1) % MOUNDS.size()
	snow_mole.global_position = MOUNDS[current_mound_index].global_position
		
func start_idle() : 
	if snow_mole_anim_sprite.animation != "idle" or not snow_mole_anim_sprite.is_playing():
		snow_mole_anim_sprite.play("idle")

func is_player_detected() -> bool : 
	return ray_left.is_colliding() or ray_right.is_colliding()
	
func flip_snow_mole() : 
	if ray_left.is_colliding():
		snow_mole.scale.x = -1
	elif ray_right.is_colliding():
		snow_mole.scale.x = 1


func _on_switch_mounds_timer_timeout() -> void:
	current_state = "SWITCHING_MOUND"
	
func _on_underground_timer_timeout() -> void:
	switch_mounds()
	snow_mole.velocity = Vector2.ZERO
	snow_mole.visible = true
	current_state = "IDLING"

func _on_attacking_cooldown_timeout() -> void:
	has_attacked_once = false
	has_left_floor_to_attack = false

######################"" DEBUG ############################
func get_debug_state() : 
	debug_state.text = current_state
