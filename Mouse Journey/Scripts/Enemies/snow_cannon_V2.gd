class_name SnowCanonEnemy
extends CharacterBody2D

@export_enum("IDLE", "PATROLING", "AIMING", "SHOOTING", "DEAD") var current_state = "PATROLING"

@export var ray_right : RayCast2D
@export var ray_left : RayCast2D
@export var platform_check : RayCast2D

@export var speed : float = 20.0

@export_enum("GAUCHE", "DROITE") var start_direction = "GAUCHE"
var current_direction : int = 1


var targetR
var targetL

var should_flip : bool = false

func _ready() -> void:
	current_direction = -1 if start_direction == "GAUCHE"  else 1
	
	scale.x *= current_direction

func _physics_process(delta: float) -> void:
	match current_state : 
		"IDLE" : 
			player_detection()
			
		"PATROLING" : 
			move()
			
			if is_on_wall() : 
				should_flip = true
			if not platform_check.is_colliding() : 
				should_flip = true
			
			if should_flip : 
				flip_direction()
			
		"AIMING" : 
			pass
		"SHOOTING" : 
			pass
		"DEAD" : 
			pass

func player_detection() : 
	targetR = ray_right.get_collider()
	targetL = ray_left.get_collider()
	
	if (targetL and targetL is PlayerClass) or (targetR and targetR is PlayerClass): 
		if current_state == "IDLE" : 
			current_state = "AIMING"
	else : 
		if current_state != "DEAD" : 
			current_state = "IDLE"
		
func flip_direction() : 
	current_direction *= -1
	platform_check.position.x *= -1
	should_flip = false
	
func move() : 
	velocity.x = speed * current_direction
	move_and_slide()
