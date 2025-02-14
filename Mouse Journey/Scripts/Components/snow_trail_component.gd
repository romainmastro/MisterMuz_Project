class_name ClassSnowTrailParticles
extends Node

@export_group("Nodes")
@export var running_particles : CPUParticles2D
@export var sliding_particles : CPUParticles2D
@export var jumping_particles : CPUParticles2D
@export var landing_particles : CPUParticles2D
@export var marker : Marker2D
@export var sprite : AnimatedSprite2D
@export var advanced_jump_component : ClassAdvancedJumpComponent


func _ready() -> void:
	advanced_jump_component.landed.connect(handle_landing_particles)

func handle_landing_particles() :
	landing_particles.global_position = marker.global_position 
	landing_particles.restart()

func is_snow_particles(body : CharacterBody2D, is_jumping : bool, is_sliding : bool) : 
	#running
	if body.is_on_floor() and body.velocity.x != 0 : 
		return true
	# sliding
	elif is_sliding : 
		return true
	#jumping
	elif is_jumping : 
		return true

func handle_snow_particles(body : CharacterBody2D, is_running : bool, is_sliding : bool, is_jumping : bool,  dir : float) : 

	var current_particles : CPUParticles2D = running_particles
	
	#get direction of the sprite
	dir = -1 if sprite.flip_h else 1
	
	# Particles for running
	if is_running and not is_sliding and not is_jumping : 
		current_particles = running_particles
	# Particles for sliding
	elif is_sliding and not is_jumping :  
		current_particles = sliding_particles
	# Particles for Jumping
	elif is_jumping:
		current_particles = jumping_particles
	
	# place the particle on the vertical axis
	current_particles.global_position.y = marker.global_position.y
	
	# place the particle on the horizontal axis : necessary when sprite is flipped
	if dir == 1 : 
		match current_particles : 
			running_particles : 
				current_particles.global_position.x = marker.global_position.x - 5 
			sliding_particles : 
				current_particles.global_position.x = marker.global_position.x
			jumping_particles : 
				current_particles.global_position.x = marker.global_position.x
	elif dir == -1 : 
		match current_particles : 
			running_particles : 
				current_particles.global_position.x = marker.global_position.x + 5 
			sliding_particles : 
				current_particles.global_position.x = marker.global_position.x
			jumping_particles : 
				current_particles.global_position.x = marker.global_position.x
	
	# change the direction of the particles according to the direction of the sprite
	if current_particles == running_particles or current_particles == sliding_particles : 
		current_particles.direction.x = dir
	else : # jumping particles /landing particles: just below the feet (no directionnal change necessary)
		current_particles.direction.x = 0
		
	if is_snow_particles(body, is_jumping, is_sliding) : 
		current_particles.emitting = true
	else : 
		current_particles.emitting = false
