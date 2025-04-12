extends Path2D

@export var loop : bool = true
@export var speed_for_closed_paths : float = 2.0
@export var speed_scale_for_open_paths : float = 1.0

@export var path : PathFollow2D
@export var animation_player : AnimationPlayer

func _ready() -> void:
	if loop == false : # for open path
		animation_player.play("move")
		animation_player.speed_scale = speed_scale_for_open_paths
		set_physics_process(false)
		

func _process(delta: float) -> void:
	path.progress += speed_for_closed_paths # for closed path
