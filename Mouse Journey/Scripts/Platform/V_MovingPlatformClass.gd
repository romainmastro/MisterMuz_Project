class_name VMovingPlatformClass
extends CharacterBody2D

@export_group("Settings")
@export var vitesse_sec : float = 50.0 # speed in pixels/sec
@export var distance_pixel : float = 64.0 # travel distance
enum Moveset {haut, bas}
@export var direction := Moveset.haut

var move_direction := -1 # -1 = up, 1 = down
var origin : Vector2
var target_pos : Vector2
var target_velocity := Vector2.ZERO
var smoothing := 5.0 # tweak for smoother lerp

func _ready():
	origin = global_position
	move_direction = -1 if direction == Moveset.haut else 1
	target_pos = origin + Vector2(0, distance_pixel * move_direction)

func _physics_process(delta: float) -> void:
	var to_target = target_pos - global_position
	
	# Reverse direction when close to target
	if abs(to_target.y) < 1.0:
		reverse_direction()

	# Set target vertical velocity
	target_velocity = Vector2(0, move_direction * vitesse_sec)

	# Smooth transition to velocity
	velocity.y = lerp(velocity.y, target_velocity.y, delta * smoothing)
	
	move_and_slide()

	# Reverse if we hit ceiling or floor
	if is_on_floor():
		reverse_direction()

func reverse_direction():
	move_direction *= -1
	target_pos = origin + Vector2(0, distance_pixel * move_direction)
