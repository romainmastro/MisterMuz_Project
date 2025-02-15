class_name ClassHurtboxComponent 
extends Node

# Register the collision to remove points [see HealthComponent for damage function]

signal damage(damage_amount : int)
signal hurt_animation

@export_group("Nodes")
@export var hurtbox : Area2D
@export var grace_timer : Timer
@export var player : CharacterBody2D
@export var health_component : ClassHealthComponent

@export_group("Settings")
@export var invincible_frame = 0.2
@export var knockback_force = 120 
@export var vertical_knockback = -100
@export var time_knockback = 0.15
@export var time_respawn = 0.2

var is_invincible : bool = false

var tween_KB : Tween
var tween_RS : Tween

func _ready() -> void:
	hurtbox.area_entered.connect(area_entered)
	grace_timer.wait_time = invincible_frame


func knockback(body: CharacterBody2D) -> void:
	
	tween_KB = create_tween()
	#body.velocity.x = -knockback_force * sign(body.velocity.x)
	tween_KB.tween_property(body, "velocity:x", body.velocity.x -knockback_force * sign(body.velocity.x), 0.15)

	#body.velocity.y = vertical_knockback
	tween_KB.parallel().tween_property(body, "velocity:y", vertical_knockback, time_knockback)

func respawn_to_last_safe_position(body : CharacterBody2D) : 
	tween_RS = create_tween()
	tween_RS.tween_property(body, "global_position", GlobalPlayerStats.last_safe_position, time_respawn)
	
	
func area_entered(area : Area2D) : 
	grace_timer.start()
	# List the different enemies for different damage amount
	match is_invincible : 
		true : 
			return
		false : 
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
					knockback(player)
				
func _on_grace_timer_timeout() -> void:
	is_invincible = false
	
