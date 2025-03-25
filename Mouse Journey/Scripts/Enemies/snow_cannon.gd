extends Node2D

@export var me : CharacterBody2D
@export var sprite_body : AnimatedSprite2D
@export var sprite_wheels : AnimatedSprite2D

@export var gravity_component : ClassGravityComponent

@export_enum("gauche", "droite") var direction_départ = "droite"
var speed : float = 40.0
var direction : int = 1


func _ready() -> void: 
	match direction_départ : 
		"gauche" : 
			direction = -1
		"droite" : 
			direction = 1
	# init animation
	sprite_body.play("body_move_right")
	sprite_wheels.play("wheels_move_right")

func _physics_process(delta: float) -> void:
	gravity_component.handle_gravity(me, delta)
	
	#move
	me.velocity.x = speed * direction
	me.move_and_slide()
	#patrol
	reverse_direction_on_collision()
	#animation
	handle_animations()
	

func reverse_direction_on_collision() : 
	if me.is_on_wall() : 
		direction = -direction

func handle_animations() : 
	match direction : 
		-1 : 
			sprite_body.play("body_move_left")
			sprite_wheels.play("wheels_move_left")
		1 : 
			sprite_body.play("body_move_right")
			sprite_wheels.play("wheels_move_right")
