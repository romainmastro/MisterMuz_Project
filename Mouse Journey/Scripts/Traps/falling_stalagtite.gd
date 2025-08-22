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
		GlobalEnemyManager.play_sound_2D($Sounds/CrashingFx)
		#await get_tree().create_timer(0.05).timeout
		$Sprite2D.visible = false
		await $Sounds/CrashingFx.finished
		
		call_deferred("queue_free")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox") : 
		call_deferred("queue_free")


func _on_shaking_timer_timeout() -> void:
	await get_tree().create_timer(randf_range(0.2, 0.5)).timeout
	animation_player.play("shake_idle")
	shaking_timer.wait_time = randf_range(2.0, 2.5)

func play_shaking() : 
	GlobalEnemyManager.play_sound_2D($Sounds/Shaking3)
