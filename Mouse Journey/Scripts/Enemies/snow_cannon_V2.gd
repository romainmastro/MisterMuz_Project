class_name SnowCanonEnemy
extends CharacterBody2D

@export_enum("IDLE", "AIMING", "SHOOTING", "DEAD") var current_state = "IDLE"

@export var ray_right : RayCast2D
@export var ray_left : RayCast2D

@export_enum("GAUCHE", "DROITE") var start_direction = "GAUCHE"
var current_direction : int = 1


var targetR
var targetL

func _ready() -> void:
	current_direction = -1 if start_direction == "GAUCHE"  else 1
	
	scale.x *= current_direction

func _physics_process(delta: float) -> void:
	match current_state : 
		"IDLE" : 
			player_detection()
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
		current_state = "AIMING"
		
func should_flip() : 
	pass
	
