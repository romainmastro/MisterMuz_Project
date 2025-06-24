#class_name SnowCanonEnemy
extends enemy_class

@export var me : CharacterBody2D
@export var sprite_body : AnimatedSprite2D
@export var sprite_wheels : AnimatedSprite2D
@export var ray : RayCast2D
@export var ray_detectionRight : RayCast2D
@export var ray_detectionLeft : RayCast2D

@export var muzzle : Node2D
@onready var snowball_proj = preload("res://Scenes/Enemies/snowball_proj2.tscn")
@export var snowball_proj_speed : float = 30
@export var shooting_timer : Timer
@export var shooting_delay : float = 1.3

@export var gravity_component : ClassGravityComponent

@export_enum("gauche", "droite") var direction_départ = "droite"
var speed : float = 25.0
var direction : int = 1

@export_enum("patroling", "shooting", "dead") var state = "patroling"

@export var ray_offset : int = 10
@export var ray_detection_offset : int = 8
@export var ray_detection_target_length : int = 100
@export var muzzle_offset : int = 10

var shoot_anim_activate : bool = false


func _ready() -> void: 
	super()
	
	scale = Vector2(0.8, 0.8)
	
	shooting_timer.wait_time = shooting_delay
	ray_detectionLeft.target_position.x = -ray_detection_target_length
	ray_detectionRight.target_position.x = ray_detection_target_length
	
	match direction_départ : 
		"gauche" : 
			direction = -1
			# init animation
			sprite_body.play("body_move_left")
			sprite_wheels.play("wheels_move_left")
			
		"droite" : 
			direction = 1
			# init animation
			sprite_body.play("body_move_right")
			sprite_wheels.play("wheels_move_right")
	
func _physics_process(delta: float) -> void:
	gravity_component.handle_gravity(me, delta)
	match state : 
		"patroling" : 
			shooting_timer.stop()
			#move
			me.velocity.x = speed * direction
			me.move_and_slide()
			#patrol
			reverse_direction_on_wall_collision()
			check_is_on_platform()
			
		"shooting" :
			reverse_direction_on_wall_collision()
			shoot() 

	if not state == "dead" :
		update_ray_offsets()
		update_active_ray()
		update_muzzle_position()
		player_detection()

	update_animations()

func update_ray_offsets() -> void:
	ray.position.x = ray_offset * direction

func update_muzzle_position() : 
	muzzle.position.x = muzzle_offset * direction

func reverse_direction_on_wall_collision() : 
	if me.is_on_wall() : 
		direction = -direction

func update_animations() : 
	match state : 
		"patroling" : 
			match direction : 
				-1 : 
					sprite_body.play("body_move_left")
					sprite_wheels.play("wheels_move_left")
				1 : 
					sprite_body.play("body_move_right")
					sprite_wheels.play("wheels_move_right")
		"shooting" :
			if shoot_anim_activate == true : 
				match direction : 
					-1 : 
						sprite_wheels.play("wheels_shoot_left")
						sprite_body.play("shoot_left")
					1 : 
						sprite_wheels.play("wheels_shoot_right")
						sprite_body.play("shoot_right")
		"dead" : 
			await do_hit_stop()
			deactivate_collisions()
			sprite_wheels.play("death")
			sprite_body.play("death")

func deactivate_collisions() : 
	collision_shape.set_deferred("disabled", true)
	hitbox.set_deferred("monitorable", false)
	hitbox.set_deferred("monitoring", false)
	deadzone.set_deferred("monitorable", false)
	deadzone.set_deferred("monitoring", false)

func check_is_on_platform() : 
	if not ray.is_colliding() : 
		direction = -direction

func update_active_ray():
	if direction == -1:
		ray_detectionLeft.enabled = true
		ray_detectionRight.enabled = false
	else : 
		ray_detectionLeft.enabled = false
		ray_detectionRight.enabled = true
	

func player_detection() -> void:
	var colR = ray_detectionRight.get_collider() 
	var colL = ray_detectionLeft.get_collider()

	if (colR and colR is PlayerClass) or (colL and colL is PlayerClass):
		state = "shooting"
	else:
		state = "patroling"



##### SHOOT #####
var sb : Node2D
func shoot() : 
	if shooting_timer.is_stopped(): 
		shooting_timer.start()
		shoot_anim_activate = true
		sb = snowball_proj.instantiate()
		sb.global_position = muzzle.global_position
		sb.direction = direction
		sb.speed = snowball_proj_speed
		
		get_tree().root.add_child(sb)
		

###### DEAD #####
func _on_dead_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player_StompBox") : 
		state = "dead"

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite_wheels.animation == "death" :
		
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.AQUA, 0.1)
		tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.1)
		tween.tween_property(self, "modulate", Color.WHITE, 0.1)
		await tween.finished
		
		$DeathParticles.emitting = true
		sprite_body.visible = false
		sprite_wheels.visible = false
		await get_tree().create_timer(0.6).timeout
		queue_free()
		
	
	elif (sprite_wheels.animation == "wheels_shoot_left" or sprite_wheels.animation == "wheels_shoot_right"): 
		shoot_anim_activate = false


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("traps") : 
		direction = -direction
