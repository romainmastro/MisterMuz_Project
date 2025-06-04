extends Marker2D

@export var enemy_type := "SnowMan"
@export var get_respawned : bool = true
var was_killed : bool = false

func _ready() -> void:
	visible = false
