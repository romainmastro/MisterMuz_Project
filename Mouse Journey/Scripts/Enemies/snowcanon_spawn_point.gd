extends Marker2D

@export var enemy_type := "SnowCanon"
@export_enum("gauche", "droite") var direction_départ = "droite"
@export var speed : float = 25.0

func _ready() -> void:
	visible = false
