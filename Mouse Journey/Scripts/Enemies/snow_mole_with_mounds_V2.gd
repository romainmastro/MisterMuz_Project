extends Node2D

@export var snow_mole : CharacterBody2D
@export var snow_mole_anim_sprite : AnimatedSprite2D
@export var MOUNDS : Array[Sprite2D]
var current_mound_index : int = 0
@export var switch_mound_timer : Timer
@export var underground_timer : Timer

@export_enum("IDLING", "SWITCHING_MOUND","TRAVELING_UNDERGROUND", "ATTACKING", "DEAD") var current_state = "IDLING"
@export var gravity : float = 600.0
@export var hop_force : float = -80.0
var hop_initiated : bool = false
var has_left_floor : bool = false

var snow_mole_scale : Vector2 = Vector2(0.8, 0.8)

func _ready() -> void:
	start_idle()
	snow_mole.global_position = MOUNDS[0].global_position 
	snow_mole.scale = snow_mole_scale

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	

	match current_state : 
		
		"IDLING" : 
			hop_initiated = false
			has_left_floor = false
			#animation
			start_idle()
			
			if switch_mound_timer.is_stopped() : 
				switch_mound_timer.start()
		
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
					
		
	snow_mole.move_and_slide()


func apply_gravity(delta : float) : 
	snow_mole.velocity.y += gravity * delta

func switch_mounds() : 
	current_mound_index = (current_mound_index + 1) % MOUNDS.size()
	snow_mole.global_position = MOUNDS[current_mound_index].global_position
		
func start_idle() : 
	snow_mole_anim_sprite.play("idle")


func _on_switch_mounds_timer_timeout() -> void:
	current_state = "SWITCHING_MOUND"
	

func _on_underground_timer_timeout() -> void:
	switch_mounds()
	snow_mole.velocity = Vector2.ZERO
	snow_mole.visible = true
	current_state = "IDLING"

	
