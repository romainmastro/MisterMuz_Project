extends Node2D

@onready var playerScene = preload("res://Scenes/player_v_2.tscn")
var player : PlayerClass = null

@export var world: Node

var current_level : Node = null

func _ready() -> void: 
	# 1 load level
	load_current_level()
	await get_tree().process_frame
	# 2 load player at the right position
	starting_position(current_level)
	# 3 Player initialisation 
	init_player()
	# 4 Spawn enemies on the map
	GlobalEnemyManager.spawn()

func load_current_level() : 
	var level_scene = GlobalMenu.get_current_level()
	current_level = level_scene.instantiate()
	world.add_child(current_level)
	
	await get_tree().process_frame
	
	var start = current_level.get_node_or_null("Sign_Start_Level")
	if start : 
		player = playerScene.instantiate()
		player.global_position = start.global_position
		world.add_child(player)
		GlobalPlayerStats.current_checkpoint = player.global_position
	else:
		print(" 'Sign_Start_Level' not found in", current_level.name)

func starting_position(level) : 
	player.position = level.get_node("Sign_Start_Level").position
	GlobalPlayerStats.current_checkpoint = player.position

func init_player() : 
	GlobalPlayerStats.player_current_HP = GlobalPlayerStats.player_max_HP
	GlobalPlayerStats.current_cheese_nb = 0
	GlobalPlayerStats.current_frostberry_number = 0
	# send signal to update HUD
	GlobalPlayerStats.update_berry_number.emit()
	GlobalPlayerStats.current_lives_number = 1
	# send signal to update HUD
	GlobalPlayerStats.update_life_number.emit()
