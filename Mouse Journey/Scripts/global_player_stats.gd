extends Node

#########################" HP SYSTEM #############################

@export var player_current_HP : float = 0
@export var player_max_HP : float = 3
@export var is_dead : bool = false

@export var current_lives_number : int = 2
@export var max_lives_number : int = 10

var current_cheese_nb : float = 0
signal max_hp_changed

var invincible_frame : bool = false

var max_frostberry_number : int = 100
var current_frostberry_number : int = 0
signal update_berry_number
signal gain_one_life

######################## CHECKPOINTS ###############################
@export var current_checkpoint : Vector2 = Vector2.ZERO

# store the current position 
@export var last_safe_position : Vector2 = Vector2.ZERO
var safe_position_offset : int = 8

######################### LEVELS ################################
# store the current Level
enum Levels {Level1, Level2, Level3, Level4}
@export var current_level := Levels.Level1 # by default Level1
@export var future_level := Levels.Level2

######################## SIGNALS #############################
# signal and variable for treasures : 
signal has_boots_gloves_suit_signal
@export var has_boots_gloves_suit : bool = false

signal has_snowHat_signal
@export var has_snow_hat : bool = false # changed in treasure_chest_snowhat.gd to turn to true

signal has_muffler_signal
@export var has_muffler : bool = false


signal show_congrats_screen # emitted by end_level_checkpoint
signal next_level #emitted by CongratsScreen
signal replay #emitted by CongratsScreen
