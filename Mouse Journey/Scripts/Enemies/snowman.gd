class_name SnowmanEnemy
extends CharacterBody2D


@export var gravity_component : ClassGravityComponent
@export var animated_sprite : AnimatedSprite2D
@export var hitbox : Area2D
@export var deadzone : Area2D
@export var collision_shape : CollisionShape2D
@export var ray : RayCast2D

@export_enum("gauche", "droite") var direction_départ = "droite"
@export var speed : float = 30
@export var damage_amount : float = 1
@export var ray_offset : int = 10
var direction : float = 1
var is_dead : bool = false

var should_flip : bool = false

func _ready() -> void:
	
	match direction_départ : 
		"droite" : 
			direction = 1
			animated_sprite.play("walk_right")
		"gauche" : 
			direction = -1
			animated_sprite.play("walk_left")
			ray.position.x *= -1
	
func _physics_process(delta: float) -> void:
	
	gravity_component.handle_gravity(self, delta)
	
	if not is_dead : 
		velocity.x = speed * direction
		move_and_slide()
		
		if is_on_wall() : 
			should_flip = true
		
		if not ray.is_colliding() : 
			should_flip = true
		
		if should_flip : 
			flip_direction()
		
		update_animation()
		
		update_ray_offset()

func flip_direction() : 
	direction *= -1
	ray.position.x *= -1
	should_flip = false

func update_ray_offset() : 
	ray.position.x = ray_offset * direction

func get_direction() -> float : 
	return direction

func update_animation() : 
	direction = get_direction()
	
	if direction == 1 and animated_sprite.animation != "walk_right" : 
		animated_sprite.play("walk_right")
		
	elif direction == -1 and animated_sprite.animation != "walk_left" : 
			animated_sprite.play("walk_left")

	
func handle_death():
	if is_dead : 
		return
	is_dead = true
	collision_shape.set_deferred("disabled", true)
	hitbox.set_deferred("monitorable", false)
	hitbox.set_deferred("monitoring", false)
	deadzone.set_deferred("monitorable", false)
	deadzone.set_deferred("monitoring", false)

	await do_hit_stop()

		## flash 
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.AQUA, 0.1)
	tween.chain().tween_property(self, "modulate", Color.TRANSPARENT, 0.1)
	tween.chain().tween_property(self, "modulate", Color.WHITE, 0.1)
	
	animated_sprite.play("death")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "death" :
		$DeathParticles.emitting = true
		animated_sprite.visible = false
		await get_tree().create_timer(0.6).timeout
		queue_free()


func _on_dead_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player_StompBox") : 
		print("snowman is Dead")
		handle_death()

func do_hit_stop(duration := 0.5, slowdown_factor := 0.5) -> void:
	Engine.time_scale = slowdown_factor
	await get_tree().create_timer(duration * slowdown_factor, true).timeout
	Engine.time_scale = 1.0
