class_name SnowmanEnemy
extends enemy_class

@export var gravity_component : ClassGravityComponent
@export var ray : RayCast2D
@export_enum("gauche", "droite") var direction_départ = "droite"
@export var speed : float = 30
@export var damage_amount : float = 1
@export var ray_offset : int = 10
var direction : float = 1

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

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("traps") : 
		should_flip = true
