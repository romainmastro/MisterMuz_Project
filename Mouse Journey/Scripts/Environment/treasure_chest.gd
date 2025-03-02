extends Area2D

@export var closed_chest_sprite : Sprite2D
@export var opened_chest_sprite : Sprite2D

func _ready() -> void:
	closed_chest_sprite.show()
	opened_chest_sprite.hide()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass :
		show_opened_chest()
		GlobalPlayerStats.has_boots_gloves = true
		GlobalPlayerStats.has_boots_gloves_signal.emit() # listened by movement_with_slide_component.gd to update the movement accel/deccel variables

func show_opened_chest() : 
	closed_chest_sprite.hide()
	opened_chest_sprite.show()
