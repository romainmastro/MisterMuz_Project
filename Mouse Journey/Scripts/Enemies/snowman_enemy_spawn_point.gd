extends Marker2D

@export var enemy_type := "SnowMan"
@export var speed := 30
@export_enum("gauche", "droite") var direction_départ = "droite"

func _ready() -> void:
	visible = false
