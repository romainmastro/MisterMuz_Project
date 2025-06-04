extends Marker2D

@export var enemy_type := "SnowMole"
@export var hop_force : float = -80.0
@export var attacking_force : float = -200.0
@export var switch_mound_wait_time : float = 1
@export var underground_timer_wait_time : float = 1

func _ready() -> void:
	visible = false
