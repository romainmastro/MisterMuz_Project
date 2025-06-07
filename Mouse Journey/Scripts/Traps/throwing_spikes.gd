class_name Throwing_spikes
extends enemy_class

var speed : float = 0
var direction : int = 1

func flip_sprite(direct) : 
	animated_sprite.flip_h = true if direct == -1 else false
		
func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta

func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer : 
		call_deferred("queue_free")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox") : 
		call_deferred("queue_free")

func _on_timer_timeout() -> void:
	call_deferred("queue_free")
