class_name HMovingPlatformClass
extends CharacterBody2D

@export_group("Settings")
@export var vitesse_sec : float = 30.0 # Max speed in pixels/sec
@export var distance_pixel : float = 64.0
@export var smoothing := 5.0 # Higher = snappier, lower = smoother
enum Moveset {gauche, droite}
@export var direction := Moveset.droite

var origin : Vector2
var target_pos : Vector2
var move_direction := 1
var target_velocity := Vector2.ZERO

func _ready():
	origin = global_position
	move_direction = 1 if direction == Moveset.droite else -1
	target_pos = origin + Vector2(distance_pixel * move_direction, 0)

func _physics_process(delta):
	var to_target = target_pos - global_position

	# Reverse direction if close enough
	if abs(to_target.x) < 1.0:
		move_direction *= -1
		target_pos = origin + Vector2(distance_pixel * move_direction, 0)

	# Desired velocity
	target_velocity = Vector2(move_direction * vitesse_sec, 0)

	# Smooth the transition toward the target velocity
	velocity.x = move_toward(velocity.x, target_velocity.x, delta * smoothing * vitesse_sec)
	
	move_and_slide()
	
	if is_on_wall() : 
		move_direction *= -1
		target_pos = origin + Vector2(distance_pixel * move_direction, 0)
