class_name TreasureClass
extends Area2D

@export var closed_chest_sprite : Sprite2D
@export var opened_chest_sprite : Sprite2D

@export var treasure_open_fx : AudioStreamPlayer
@export var treasure_chest_click : AudioStreamPlayer

func _ready() -> void:
	closed_chest_sprite.show()
	opened_chest_sprite.hide()

func show_opened_chest() : 
	closed_chest_sprite.hide()
	opened_chest_sprite.show()
	
	GlobalEnemyManager.play_sound_1D(treasure_chest_click)
	await get_tree().create_timer(0.3).timeout
	GlobalEnemyManager.play_sound_1D(treasure_open_fx)
	
	
