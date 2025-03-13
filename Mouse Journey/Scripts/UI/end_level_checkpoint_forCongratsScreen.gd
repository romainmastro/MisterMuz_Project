extends Area2D

@export var fire_lit : AnimatedSprite2D

func _ready() -> void:
	fire_lit.show()
	fire_lit.play("fire_lit")
