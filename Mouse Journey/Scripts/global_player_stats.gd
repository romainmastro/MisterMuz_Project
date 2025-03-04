extends Node

@export var player_current_HP : float = 0
@export var player_max_HP : float = 3

var current_cheese_nb : float = 0
@warning_ignore("unused_signal")signal max_hp_changed


var invincible_frame : bool = false

@export var current_checkpoint : Vector2 = Vector2.ZERO

# store the current position 
@export var last_safe_position : Vector2 = Vector2.ZERO
var safe_position_offset : int = 8

# store the current Level
@export var current_level : TileMapLayer

# signal and variable for treasures : 
@warning_ignore("unused_signal") signal has_boots_gloves_suit_signal
@export var has_boots_gloves_suit : bool = false

@warning_ignore("unused_signal") signal has_snowHat_signal
@export var has_snow_hat : bool = false

@warning_ignore("unused_signal") signal has_muffler_signal
@export var has_muffler : bool = false
