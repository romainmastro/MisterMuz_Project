class_name ClassHurtboxComponent 
extends Area2D

# Register the collision to remove points [see HealthComponent for damage() function]

signal damage(damage_amount : int)
signal hurt_animation

@export_group("Nodes")
@export var hurtbox : Area2D
@export var grace_timer : Timer
@export var player : CharacterBody2D
@export var health_component : ClassHealthComponent
@export var animation_component : ClassAnimationComponent

@export_group("Settings")
@export var invincible_frame := 0.5
@export var medium_knockback_force := 100.0
@export var heavy_knockback_force := 300.0 
@export var vertical_knockback := -100.0
@export var time_knockback := 0.15
@export var time_respawn := 0.3

var is_invincible : bool = false

var tween_KB : Tween

func _ready() -> void:
	hurtbox.area_entered.connect(area_entered) # stalagmites/stalagtites traps
	hurtbox.body_entered.connect(body_entered) # snowball trap
	
	grace_timer.wait_time = invincible_frame
	health_component.just_died.connect(stop_tween)

func knockback(body: CharacterBody2D, knockback_force : float) -> void:
	
	var kb_dir = sign(body.velocity.x)
	
	if kb_dir == 0 : 
		kb_dir = sign(animation_component.facing_direction())
	
	tween_KB = create_tween()
	tween_KB.tween_property(body, "velocity:x", body.velocity.x -knockback_force * kb_dir, time_knockback)
	tween_KB.parallel().tween_property(body, "velocity:y", vertical_knockback, time_knockback)
	tween_KB.finished.connect(stop_tween)

func respawn_to_last_safe_position(body : CharacterBody2D) :
	var safe_position = GlobalPlayerStats.last_safe_position
	await get_tree().create_timer(0.5).timeout
	player.velocity = Vector2.ZERO
	player.hide()
	body.global_position = safe_position
	player.show()
	
func area_entered(area : Area2D) : 
	grace_timer.start()
	# List the different enemies for different damage amount
	match is_invincible : 
		true : 
			return
		false : 
##########################################################################
#################### ADD TRAPS ###########################################
###########################################################################
			if area is ClassTrapRespawn: 
				damage.emit(area.damage_amount)
				hurt_animation.emit()
				is_invincible = true
				if not health_component.is_dead : 
					respawn_to_last_safe_position(player)

			elif area is ClassTrapKnockBack : 
				damage.emit(area.damage_amount)
				hurt_animation.emit()
				is_invincible = true
				if not health_component.is_dead : 
					knockback(player, medium_knockback_force)
					player.velocity = Vector2.ZERO
##########################################################################
#################### ADD ENEMIES ##########################################
###########################################################################
			elif area is EnemyHitboxClass : 
				damage.emit(area.damage_amount)
				hurt_animation.emit()
				is_invincible = true
				if not health_component.is_dead : 
					knockback(player, medium_knockback_force)
					player.velocity = Vector2.ZERO
					
			elif area is Snowball_proj2 : 
				damage.emit(area.damage_amount) # Listened by Health Component
				hurt_animation.emit()
				is_invincible = true
				if not health_component.is_dead : 
					knockback(player, medium_knockback_force)
					player.velocity = Vector2.ZERO

func body_entered(body : Node2D) : 
	grace_timer.start()
	
	match is_invincible : 
		true : 
			#knockback(player, heavy_knockback_force)
			return
		false : 
			if body is TrapSnowballClass:
				damage.emit(body.damage_amount)
				hurt_animation.emit()
				is_invincible = true
				if not health_component.is_dead : 
					knockback(player, heavy_knockback_force)
					player.velocity = Vector2.ZERO

func _on_grace_timer_timeout() -> void:
	is_invincible = false
	
func stop_tween() : 
	if tween_KB and tween_KB.is_valid() : 
		tween_KB.kill()
