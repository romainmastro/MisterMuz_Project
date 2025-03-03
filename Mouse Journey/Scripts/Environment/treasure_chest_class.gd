class_name TreasureClass
extends Area2D

@export var closed_chest_sprite : Sprite2D
@export var opened_chest_sprite : Sprite2D

func _ready() -> void:
	closed_chest_sprite.show()
	opened_chest_sprite.hide()

func show_opened_chest() : 
	closed_chest_sprite.hide()
	opened_chest_sprite.show()
