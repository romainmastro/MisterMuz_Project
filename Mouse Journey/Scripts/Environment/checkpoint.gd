extends Area2D

@export_group("Nodes")
@export var fire : AnimatedSprite2D

func _ready() -> void : 
	fire.hide()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		GlobalPlayerStats.current_checkpoint = global_position
		fire.show()
