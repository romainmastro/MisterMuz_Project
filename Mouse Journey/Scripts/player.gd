class_name PlayerClass
extends CharacterBody2D

@export_subgroup("Nodes")
@export var gravity_component : ClassGravityComponent
@export var input_component : ClassInputComponent
@export var movement_component : ClassMovementComponent
@export var advanced_jump_component : ClassAdvancedJumpComponent
@export var animation_component : ClassAnimationComponent
@export var health_component : ClassHealthComponent
@export var hurtbox_component : ClassHurtboxComponent

@export var camera : Camera2D

func _ready() -> void:
	health_component.init_health()
	
	camera.limit_bottom = get_viewport_rect().size.y
	camera.limit_left = 0
	#camera.limit_right = get_viewport_rect().size.x
	#camera.limit_top = -144

func _physics_process(delta: float) -> void:
	
	gravity_component.handle_gravity(self, delta)
	
	#HORIZONTAL INPUT + MOVEMENT
	movement_component.handle_x_movement(self, input_component.x_input)
	
	#JUMP INPUT + MOVEMENT
	advanced_jump_component.handle_jump(self, input_component.get_jump_input(), input_component.get_jump_released_input())
	
	#ANIMATION
	animation_component.handle_flip_sprite(input_component.x_input)
	animation_component.handle_run_animation(velocity.x)
	animation_component.handle_jump_animation(advanced_jump_component.is_going_up, gravity_component.is_falling)
	
	#HEALTH
	# when the player dies i.e. current_HP <= 0
	health_component.call_deferred("on_death")
	
	move_and_slide()
