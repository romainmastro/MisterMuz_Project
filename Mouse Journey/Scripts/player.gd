class_name PlayerClass
extends CharacterBody2D

@export_subgroup("Nodes")
@export var gravity_component : ClassGravityComponent
@export var input_component : ClassInputComponent
@export var movement_component_slide : ClassMovement_SlideComponent
@export var advanced_jump_component : ClassAdvancedJumpComponent
@export var animation_component : ClassAnimationComponent
@export var health_component : ClassHealthComponent
@export var hurtbox_component : ClassHurtboxComponent
@export var snow_trail_component : ClassSnowTrailParticles

@export var camera : Camera2D

var input_disabled = false

func _ready() -> void:
	health_component.init_health()
	movement_component_slide.init_movement_component()
	
	health_component.just_died.connect(disable_input)

func _physics_process(delta: float) -> void:
	
	if input_disabled : # when dies : useful for respawn to disable weird spawn movement
		return

	gravity_component.handle_gravity(self, delta)
	
	#HORIZONTAL INPUT + MOVEMENT + SLIDE
	movement_component_slide.handle_x_movement(self, input_component.x_input, input_component.get_slide_input())
	
	#JUMP INPUT + MOVEMENT
	advanced_jump_component.handle_jump(self, input_component.get_jump_input(), input_component.get_jump_released_input())
	
	#ANIMATION
	animation_component.handle_flip_sprite(input_component.x_input)
	animation_component.handle_run_animation(velocity.x)
	animation_component.handle_jump_animation(advanced_jump_component.is_going_up, gravity_component.is_falling)
	animation_component.handle_slide_animation(movement_component_slide.is_sliding, advanced_jump_component.is_going_up, gravity_component.is_falling)
	
	#PARTICLES
	snow_trail_component.handle_snow_particles(self, velocity.x != 0 and is_on_floor() and not movement_component_slide.is_sliding, movement_component_slide.is_sliding, advanced_jump_component.is_jumping, animation_component.facing_direction())
	
	#HEALTH
	# when the player dies i.e. current_HP <= 0
	health_component.call_deferred("on_death")
	
	store_last_walking_frame()
	
	move_and_slide()
	
	if is_on_floor() : 
		apply_floor_snap()
	
	
func store_last_walking_frame() -> void:
	if is_on_floor() and velocity.x != 0:
		GlobalPlayerStats.last_safe_position = Vector2(
			global_position.x - GlobalPlayerStats.safe_position_offset * sign(velocity.x),
			global_position.y
		)

func disable_input() : 
	input_disabled = true
	await get_tree().create_timer(0.5).timeout
	input_disabled = false
