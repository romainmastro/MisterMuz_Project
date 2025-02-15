extends Node

@export var player_current_HP : float = 0
@export var player_max_HP : float = 3

var invincible_frame : bool = false

@export var current_checkpoint : Vector2 = Vector2.ZERO

# store the current position 
@export var last_safe_position : Vector2 = Vector2.ZERO
var safe_position_offset : int = 5
