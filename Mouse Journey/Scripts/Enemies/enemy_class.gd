class_name enemy_class
extends CharacterBody2D

@export var collision_shape : CollisionShape2D
@export var hitbox : Area2D
@export var deadzone : Area2D
@export var animated_sprite : AnimatedSprite2D
@export var death_particles : CPUParticles2D

var is_dead : bool = false

func die() : 
	queue_free()

#func respawn() : 
	#activate_collisions()


func handle_death():
	if is_dead : 
		return
	is_dead = true
	deactivate_collisions()
	await do_hit_stop()

		## flash 
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.AQUA, 0.1)
	tween.chain().tween_property(self, "modulate", Color.TRANSPARENT, 0.1)
	tween.chain().tween_property(self, "modulate", Color.WHITE, 0.1)
	
	animated_sprite.play("death")
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "death" :
		death_particles.emitting = true
		animated_sprite.visible = false
		await get_tree().create_timer(0.6).timeout
		die()

func _on_dead_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player_StompBox") : 
		print("enemy is Dead")
		handle_death()

func deactivate_collisions() : 
	collision_shape.set_deferred("disabled", true)
	hitbox.set_deferred("monitorable", false)
	hitbox.set_deferred("monitoring", false)
	deadzone.set_deferred("monitorable", false)
	deadzone.set_deferred("monitoring", false)

#func activate_collisions() : 
	#collision_shape.set_deferred("disabled", false)
	#hitbox.set_deferred("monitorable", true)
	#hitbox.set_deferred("monitoring", true)
	#deadzone.set_deferred("monitorable", true)
	#deadzone.set_deferred("monitoring", true)

func do_hit_stop(duration := 0.5, slowdown_factor := 0.5) -> void:
	Engine.time_scale = slowdown_factor
	await get_tree().create_timer(duration * slowdown_factor, true).timeout
	Engine.time_scale = 1.0
