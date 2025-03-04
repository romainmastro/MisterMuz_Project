extends Node2D

@onready var snowball = preload("res://Scenes/Traps/Snowball.tscn")
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

@export var temps_apparition : float = 2.0

func _ready() -> void:
	timer.wait_time = temps_apparition
	sprite_2d.hide()

func spawner() : 
	var sb = snowball.instantiate()
	add_child(sb, true)


func _on_timer_timeout() -> void:
	spawner()
