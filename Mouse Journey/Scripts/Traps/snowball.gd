class_name TrapSnowballClass
extends RigidBody2D

@export var damage_amount : float = 1


# disappear after 5 secs
func _on_timer_timeout() -> void:
	call_deferred("queue_free")
