extends ClassTrapKnockBack
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export_group("Settings")
@export var falling_speed : float = 150
@export var shaking_timer : Timer

var has_fell : bool = false

var current_speed : float = 0


func _physics_process(delta: float) -> void:
	position.y += current_speed * delta
	
func fall() : # is called in the animation player thanks to a call method track
	current_speed = falling_speed
	has_fell = true

func _on_detector_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		shaking_timer.stop()
		animation_player.play("shake")

func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer and has_fell : 
		await get_tree().create_timer(0.05).timeout
		call_deferred("queue_free")


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox") : 
		call_deferred("queue_free")


func _on_shaking_timer_timeout() -> void:
	animation_player.play("shake_idle")
