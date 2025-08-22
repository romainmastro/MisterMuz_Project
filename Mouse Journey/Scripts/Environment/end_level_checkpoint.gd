extends Area2D

@export var fire_lit : AnimatedSprite2D

@export var fire_starting : AudioStreamPlayer
@export var fire_crackling : AudioStreamPlayer2D

func _ready() -> void:
	fire_lit.hide()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		fire_lit.show()	
		fire_lit.play("fire_lit")
		$FireStarting.play()


func _on_fire_starting_finished() -> void:
	GlobalMenu.game_transition(func(): GlobalMenu.set_game_state(GlobalMenu.GAME_STATES.LEVEL_COMPLETE_SCREEN))
