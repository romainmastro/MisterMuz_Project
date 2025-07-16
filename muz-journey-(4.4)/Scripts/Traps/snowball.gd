class_name TrapSnowballClass
extends RigidBody2D

@export var lifetime : float = 10.0
@export var timer_life : Timer


func _ready() -> void:
	timer_life.wait_time = lifetime

# disappear after 10 secs
func _on_timer_timeout() -> void:
	call_deferred("queue_free")

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox") : 
		call_deferred("queue_free")
