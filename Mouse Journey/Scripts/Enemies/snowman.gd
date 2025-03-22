class_name SnowmanEnemy
extends CharacterBody2D



@export var gravity_component : ClassGravityComponent
@export var animated_sprite : AnimatedSprite2D
@export var hitbox : Area2D
@export var deadzone : Area2D
@export var ray : RayCast2D

@export_enum("gauche", "droite") var direction_départ = "droite"
@export var speed : float = 30
@export var damage_amount : float = 1
var direction : float = 1
var is_dead : bool = false

func _ready() -> void:
	
	match direction_départ : 
		"droite" : 
			direction = 1
			animated_sprite.play("walk_right")
		"gauche" : 
			direction = -1
			animated_sprite.play("walk_left")
			ray.position.x *= -1
	
	GlobalEnemy.dead_enemy.connect(handle_death) # emitted by HurboxComponent.gd - player

func _physics_process(delta: float) -> void:
	
	gravity_component.handle_gravity(self, delta)
	
	if not is_dead : 
		velocity.x = speed * direction
		move_and_slide()
		
		if is_on_wall() : 
			direction = -direction
		
		check_platform_edge()
		
		update_animation()

func get_direction() -> float : 
	return direction

func update_animation() : 
	direction = get_direction()
	
	if direction == 1 : 
		animated_sprite.play("walk_right")
	else : 
		animated_sprite.play("walk_left")

func handle_death() : 
	is_dead = true
	hitbox.set_deferred("monitorable", false)
	hitbox.set_deferred("monitoring", false)
	deadzone.set_deferred("monitorable", false)
	deadzone.set_deferred("monitoring", false)
	# flash Red
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.chain().tween_property(self, "modulate", Color.TRANSPARENT, 0.1)
	tween.chain().tween_property(self, "modulate", Color.WHITE, 0.1)
	
	animated_sprite.play("death")

func _on_animated_sprite_2d_animation_finished() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:y", -35, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property(self, "position:y", 50, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	queue_free()

func check_platform_edge() : 
	if not ray.is_colliding() : 
		direction = -direction
		ray.position.x *= -1
