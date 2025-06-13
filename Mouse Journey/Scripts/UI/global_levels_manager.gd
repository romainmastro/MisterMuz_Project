extends Node

@export var player : PlayerClass
@export var HUD : CanvasLayer

signal level_completed

@onready var start_screen = preload("res://Scenes/UI/Main_menu.tscn")
@onready var congrats_screen = preload("res://Scenes/UI/congrats_screen.tscn")
@onready var game_over_screen = preload("res://Scenes/UI/game_over_screen.tscn")

var levels : Array[PackedScene] = [
	preload("res://Scenes/Levels/level_1_romain.tscn"),
	preload("res://Scenes/Levels/level_eline.tscn"),
	preload("res://Scenes/Levels/level_sophie.tscn"),
	]

var current_level_index : int = 0

func get_current_level() -> PackedScene : 
	return levels[current_level_index]

func go_next_level() : 
	current_level_index += 1
