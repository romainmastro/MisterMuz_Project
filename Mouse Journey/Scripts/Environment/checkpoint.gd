extends Area2D

@export_group("Nodes")
@export var fire : AnimatedSprite2D
@export var light_animator : AnimationPlayer

func _ready() -> void : 
	light_animator.active = false
	fire.hide()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		GlobalPlayerStats.current_checkpoint = global_position
		light_animator.active = true
		fire.show()
