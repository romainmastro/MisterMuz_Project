extends Node2D

@export_enum("HIDDEN", "EMERGING" , "AIMING", "SHOOTING", "HIDING", "DEAD") var current_state = "HIDDEN"

@export_group("Nodes")
@export var anim_player : AnimationPlayer
@export var snow_turret_sprite : Sprite2D
@export var vision_cone : Area2D
@export var raycast_right : RayCast2D
@export var raycast_left : RayCast2D
@export var muzzle : Marker2D
@export var aiming_timer : Timer
@export var hiding_timer : Timer

@export_group("Paramètres")
@export var max_number_snowballs : int = 1
@export_enum("gauche", "droite") var current_direction = "gauche"

var has_shot : bool = false

@onready var snowball_scene = preload("res://Scenes/Enemies/snowball_proj2.tscn")

var should_flip : bool = false
var player_detected : bool = false

func _ready() -> void:
	
	if current_direction == "gauche" : 
		should_flip = true
	else : 
		should_flip = false
		

func _physics_process(delta: float) -> void:
	
	handle_flip()
	
	match current_state : 
		"HIDDEN" :
			if hiding_timer.is_stopped() : 
				activate_vision()
			
			if has_shot  : 
				has_shot = false

			# animation : 
			anim_player.play("hidden")

			# Transitions : 
			if player_detected : 
				current_state = "EMERGING"
			else : 
				current_state = "HIDDEN"
				
		"EMERGING" :
			deactivate_vision()
			handle_aim()
			
			# animation : 
			if should_flip : 
				anim_player.play("emerging_left") 
			else : 
				anim_player.play("emerging_right")
			
			# Transition to AIMING at the end of the animation
			
		
		"AIMING" : 
			handle_aim()
			if aiming_timer.is_stopped() : 
				aiming_timer.start() #  transition to SHOOTING when timeout
			
		"SHOOTING" : 
			if not has_shot : # hasn't shot yet so can shoot
				has_shot = true
			
				# animation
				if should_flip : 
					anim_player.play("shooting_left")
				else : 
					anim_player.play("shooting_right")
					
				#shoot()
					
		"HIDING" : 
			if hiding_timer.is_stopped() : 
				hiding_timer.start()
			 #animation
			anim_player.play("hiding")
	
	#debug_state()
	
	
func handle_flip() :
	if raycast_left.is_colliding() and raycast_left.get_collider() is PlayerClass : 
		should_flip = true
	elif raycast_right.is_colliding() and raycast_right.get_collider() is PlayerClass : 
		should_flip = false
	
	if should_flip : 
		snow_turret_sprite.flip_h = true
		vision_cone.scale.x = -1
	else : 
		snow_turret_sprite.flip_h = false
		vision_cone.scale.x = 1

func activate_vision() : 
	raycast_left.enabled = true
	raycast_right.enabled = true
	vision_cone.monitorable = true
	vision_cone.monitoring = true
	
func deactivate_vision() : 
	# has already detected the player so reset the detection
	player_detected = false
	# has already detected the player so must go through emerging, aiming, shooting and hiding
	raycast_left.enabled = false
	raycast_right.enabled = false
	vision_cone.monitorable = false
	vision_cone.monitoring = false

func handle_aim() : 
	print("I'm aiming at the player")
	
func shoot() : 
	var snowball = snowball_scene.instantiate()
	snowball.direction = sign(vision_cone.scale.x)
	snowball.global_position = muzzle.global_position
	get_tree().root.add_child(snowball)

func _on_vision_cone_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		player_detected = true

func _on_aiming_timer_timeout() -> void:
	current_state = "SHOOTING"

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "emerging_left" or anim_name == "emerging_right": 
		current_state = "AIMING"
		
	elif anim_name == "shooting_left" or anim_name == "shooting_right" : 
		current_state = "HIDING"
		
	elif anim_name == "hiding" : 
		current_state = "HIDDEN"

######################### DEBUG ###################################
func debug_state() : 
	$CanvasLayer/Label.text = current_state + "__" + anim_player.current_animation
