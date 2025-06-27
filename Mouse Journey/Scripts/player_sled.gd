extends CharacterBody2D

# TODO : make level really testable with enemies/traps

@export var animated_sprite : AnimatedSprite2D
@export var sledding_particles : CPUParticles2D
@export var sledding_particles_marker : Marker2D

@export var jump_buffer_timer : Timer
@export var jump_buffer_time : float = 0.2
var jump_is_buffered : bool = false

@export var rebound_speed : float = 200

@export var coyote_timer : Timer
@export var coyote_time : float = 0.2
var jump_is_coyoted : bool = false

@export var gravity : float = 600
@export var speed : float = 100
@export var jump_force : float = 250

enum STATES{SLEDDING, JUMPING, FALLING, DEAD}
@export var current_state = STATES.SLEDDING

var was_on_floor : bool = false

func _ready() -> void:
	# init timers
	jump_buffer_timer.wait_time = jump_buffer_time
	jump_buffer_timer.one_shot = true
	
	coyote_timer.wait_time = coyote_time
	coyote_timer.one_shot = true
	
	# init particles
	sledding_particles.global_position = sledding_particles_marker.global_position

func _physics_process(delta: float) -> void:
	# COYOTE TIME : 
	if not is_on_floor() and not coyote_timer.is_stopped() : 
		pass
	if not is_on_floor() and coyote_timer.is_stopped() : 
		coyote_timer.start()
		jump_is_coyoted = true
	
	handle_gravity(delta)

	update_states()

	move_and_slide()


func update_states() : 
	if is_on_floor() : 
		match current_state : 
			STATES.SLEDDING : 
				# animation
				animated_sprite.play("sledding")
				# behaviour
				velocity.x = speed
				# transition
				if Input.is_action_just_pressed("jump") or jump_is_buffered or (Input.is_action_just_pressed("jump") and jump_is_coyoted) : 
					jump() 
					current_state = STATES.JUMPING
					coyote_timer.stop()
				# particles
				sledding_particles.emitting = true
			STATES.JUMPING, STATES.FALLING : 
				current_state = STATES.SLEDDING

	if not is_on_floor() : 
		match  current_state : 
			STATES.JUMPING : 
				# animation
				animated_sprite.play("jumping")
				print("state : jumping")
				#transitions
				if velocity.y >= 0 : 
					current_state = STATES.FALLING

			STATES.FALLING : 
				print("state : falling")
				
				if Input.is_action_just_pressed("jump") : 
					jump_buffer_timer.start()
					jump_is_buffered = true
					#jump_buffered
				
			STATES.DEAD : 
				print("state : dead")

func handle_gravity(delta : float) : 
	velocity.y += gravity * delta

func jump() : 
	velocity.y = -jump_force
	
func rebound() : 
	if velocity.y > 0 : 
		velocity.y += rebound_speed

func _on_jump_buffer_timer_timeout() -> void:
	jump_is_buffered = false

func _on_coyote_timer_timeout() -> void:
	jump_is_coyoted = false

func _on_stomp_box_area_entered(area: Area2D) -> void:
	if area is EnemyDeadZoneClass : 
		rebound()
