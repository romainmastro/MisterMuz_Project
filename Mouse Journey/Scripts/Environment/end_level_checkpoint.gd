extends Area2D

@export var fire_lit : AnimatedSprite2D

func _ready() -> void:
	fire_lit.hide()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		fire_lit.show()
		fire_lit.play("fire_lit")
		GlobalMenu.set_game_state(GlobalMenu.GAME_STATES.LEVEL_COMPLETE_SCREEN)
