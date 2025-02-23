extends Node2D

@onready var snowball = preload("res://Scenes/Traps/Snowball.tscn")
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite_2d.hide()

func spawner() : 
	var sb = snowball.instantiate()
	add_child(sb, true)


func _on_timer_timeout() -> void:
	spawner()
