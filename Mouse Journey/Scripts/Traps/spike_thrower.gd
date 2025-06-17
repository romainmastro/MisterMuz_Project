class_name Spike_thrower
extends Node2D

const THROWING_SPIKES = preload("res://Scenes/Traps/throwing_spikes.tscn")
@export var animated_sprite : AnimatedSprite2D
@export var marker : Marker2D
@export var reload_timer : Timer
@export var particles : CPUParticles2D

@export var speed : float = 50
@export_enum ("gauche", "droite") var direction_depart := 1
var direction
var marker_x_offset : int = 10
var particles_offset : int = 5
var anim : String
const DIRECTiON_DROITE := 1
const DIRECTION_GAUCHE := 0

func _ready() -> void:
	handle_flip_sprite()
		
func _on_timer_timeout() -> void:
	animated_sprite.play("shoot")
	
func handle_flip_sprite() : 
	match direction_depart : 
		DIRECTION_GAUCHE : 
			direction = -1
			animated_sprite.flip_h = true
			marker.position.x =  -marker_x_offset
			particles.position.x = -particles_offset
			
		DIRECTiON_DROITE : 
			direction = 1
			animated_sprite.flip_h = false
			marker.position.x =  marker_x_offset
			particles.position.x = particles_offset

func _on_animated_sprite_2d_animation_finished() -> void:
	particles.emitting = true
	
	var spike = THROWING_SPIKES.instantiate()
	spike.position = marker.position
	spike.speed = speed
	spike.direction = direction
	spike.flip_sprite(direction)
	add_child(spike)
