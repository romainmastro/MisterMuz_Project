extends Path2D

#@export var chemin_fermé : bool = true
@export var vitesse : float = 50
@export var path : PathFollow2D



func _process(delta: float) -> void:
	path.progress += vitesse * delta # for closed path
