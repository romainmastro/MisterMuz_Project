class_name SuperSnowmanEnemy
extends enemy_class

@onready var me = preload("res://Scenes/Enemies/super_snowman.tscn")
@export var popup_fx : AudioStreamPlayer
@export var gravity_component : ClassGravityComponent
@export var ray : RayCast2D
@export var spawn_positions : Array[Marker2D]
@export_enum("gauche", "droite") var direction_départ = "droite"
@export var speed : float = 30
@export var damage_amount : float = 1
@export var ray_offset : int = 10
var direction : float = 1

var should_flip : bool = false
var should_spawn_little_snowmen : bool = true

func _ready() -> void:
	super()
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

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("traps") : 
		should_flip = true
		
# BASE CLASS OVERRIDE : 

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "death":
		
		GlobalEnemyManager.play_sound_1D(ice_shatter_fx)
			
		death_particles.emitting = true
		animated_sprite.visible = false
		await get_tree().create_timer(0.6).timeout
		
		roll = randi_range(0, 100)
		if roll >= 1 and roll <= 20 : 
			spawn_collectible(heart_scene)
		elif roll >= 21 and roll <= 40 : 
			spawn_collectible(fruit_scene)
		elif roll >= 41 and roll <= 45 : 
			spawn_collectible(super_fruit_scene)
		else : 
			pass
		
func spawn_little_snowmen() : 
	if should_spawn_little_snowmen : 
		for i in range(2) : 
			var little_snowman = me.instantiate() as SuperSnowmanEnemy
			little_snowman.global_position = spawn_positions[i].global_position
			little_snowman.speed = randf_range(45.0, 65.0)
			little_snowman.scale = Vector2(0.7, 0.7)
			little_snowman.direction_départ = "droite" if i == 0 else "gauche"
			little_snowman.should_spawn_little_snowmen = false
			get_parent().add_child(little_snowman, true)
			
func _on_ice_shatter_finished() -> void:
	if should_spawn_little_snowmen : 
		GlobalEnemyManager.play_sound_1D(popup_fx)

func _on_pop_up_finished() -> void:
	spawn_little_snowmen()	
