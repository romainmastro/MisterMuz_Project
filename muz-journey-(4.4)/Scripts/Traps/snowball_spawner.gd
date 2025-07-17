extends Node2D

@onready var snowball = preload("res://Scenes/Traps/Snowball.tscn")
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

@export var roule_droite : bool = true
@export_range(3.0, 20.0) var vitesse := 7.0
var roule_direction : int = 1

@export var temps_apparition : float = 2.0

var sb : TrapSnowballClass

func _ready() -> void:
	timer.wait_time = temps_apparition
	sprite_2d.hide()
	
	roule_direction = 1 if roule_droite == true else -1

func spawner() : 
	sb = snowball.instantiate()
	add_child(sb, true)
	
func _on_timer_timeout() -> void:
	spawner()

func _physics_process(_delta: float) -> void:
	if sb : 
		sb.apply_torque_impulse(vitesse * roule_direction)
