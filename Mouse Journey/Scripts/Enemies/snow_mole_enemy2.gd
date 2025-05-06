extends Node2D

@export_enum("HIDDEN", "EMERGING", "AIMING", "SHOOTING", "HIDING", "DEAD") var current_state = "HIDDEN"

@export_group("Nodes")
@export var anim_player : AnimationPlayer
@export var snow_turret_sprite : Sprite2D
@export var vision_cone : Area2D
@export var raycast_right : RayCast2D
@export var raycast_left : RayCast2D
@export var muzzle : Marker2D
@export var aiming_timer : Timer
@export var hiding_timer : Timer

@export_group("Settings")
@export var max_number_snowballs : int = 1
@export_enum("gauche", "droite") var current_direction = "gauche"

var has_shot : bool = false
@onready var snowball_scene = preload("res://Scenes/Enemies/snowball_proj_arc.tscn")

var should_flip : bool = false
var player_detected : bool = false
var player_last_known_position : Vector2 = Vector2.ZERO

func _ready() -> void:
	if current_direction == "gauche":
		should_flip = true
	else:
		should_flip = false

func _physics_process(delta: float) -> void:
	handle_flip()
	handle_state()

func handle_state() -> void:
	match current_state:
		"HIDDEN":
			if hiding_timer.is_stopped():
				activate_vision()
			if has_shot:
				has_shot = false
			anim_player.play("hidden")
			if player_detected:
				current_state = "EMERGING"

		"EMERGING":
			deactivate_vision()
			
			if should_flip:
				anim_player.play("emerging_left")
			else:
				anim_player.play("emerging_right")
		
		"AIMING":
			handle_flip()
		
		"SHOOTING":
			if not has_shot:
				has_shot = true
				if should_flip:
					anim_player.play("shooting_left")
				else:
					anim_player.play("shooting_right")
					
		"HIDING":
			if hiding_timer.is_stopped():
				hiding_timer.start()
			anim_player.play("hiding")

# === Animation Notify Functions ===
func _on_animation_notify_emerging_finished() -> void:
	current_state = "AIMING"
	aiming_timer.start()

func _on_animation_notify_aiming_timeout() -> void:
	player_last_known_position = get_target()
	current_state = "SHOOTING"

func _on_animation_notify_shoot() -> void:
	shoot()

func _on_animation_notify_shooting_finished() -> void:
	current_state = "HIDING"

func _on_animation_notify_hiding_finished() -> void:
	current_state = "HIDDEN"

# === Utility functions ===
func handle_flip() -> void:
	if raycast_left.is_colliding() and raycast_left.get_collider() is PlayerClass:
		should_flip = true
	elif raycast_right.is_colliding() and raycast_right.get_collider() is PlayerClass:
		should_flip = false

	snow_turret_sprite.flip_h = should_flip
	vision_cone.scale.x = -1 if should_flip else 1

func activate_vision() -> void:
	raycast_left.enabled = true
	raycast_right.enabled = true
	vision_cone.monitorable = true
	vision_cone.monitoring = true

func deactivate_vision() -> void:
	player_detected = false
	raycast_left.enabled = false
	raycast_right.enabled = false
	vision_cone.monitorable = false
	vision_cone.monitoring = false

func get_target() -> Vector2:
	var target = get_tree().get_nodes_in_group("player")[0].global_position
	print("My target is at : ", target)
	return target
	
func shoot() -> void:
	var snowball = snowball_scene.instantiate()
	snowball.global_position = muzzle.global_position
	
	var direction = (player_last_known_position - muzzle.global_position).normalized()
	snowball.velocity = Vector2(direction.x * 70, -300)
	
	get_tree().root.add_child(snowball)

func _on_vision_cone_body_entered(body: Node2D) -> void:
	if body is PlayerClass:
		player_detected = true
