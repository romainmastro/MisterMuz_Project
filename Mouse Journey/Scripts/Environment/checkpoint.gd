extends Area2D

@export_group("Nodes")
@export var fire : AnimatedSprite2D
@export var light_animator : AnimationPlayer
@export var light_source : PointLight2D

@export var fire_starting : AudioStreamPlayer
@export var fire_crackling : AudioStreamPlayer2D

func _ready() -> void : 
	light_animator.active = false
	fire.hide()
	light_source.enabled = false

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		GlobalPlayerStats.current_checkpoint = global_position
		light_source.enabled = true
		light_animator.active = true
		if not fire.visible : 
			GlobalEnemyManager.play_sound_1D(fire_starting)
			fire.show()
		
		await fire_starting.finished
		GlobalEnemyManager.play_sound_2D(fire_crackling)
		
		
