extends Marker2D

@export var enemy_type := "Penguins"
@export var speed := 100
@export_enum("gauche", "droite") var direction_départ = "droite"

func _ready() -> void:
	visible = false
