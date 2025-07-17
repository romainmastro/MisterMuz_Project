extends Node2D

@onready var playerScene = preload("res://Scenes/player_v_2.tscn")

var player : PlayerClass = null

@export var world: Node2D

var current_level : Node = null

#TODO : problem with enemy rotation...

func _ready() -> void: 
	# 1 load level and Player
	load_current_level()
	await get_tree().process_frame
	# 2 Player initialisation 
	init_player()
	# 3 Spawn enemies on the map
	GlobalEnemyManager.spawn()
	

func load_current_level() : 
	var level_scene = GlobalMenu.get_current_level()
	
	await get_tree().process_frame
	
	# Spawn the level
	current_level = level_scene.instantiate()
	current_level.rotation = GlobalMenu.get_current_level_rotation()
	world.add_child(current_level)
	
	await get_tree().process_frame
	
	# Spawn the player
	var start = current_level.get_node_or_null("Sign_Start_Level")
	if start : 
		player = playerScene.instantiate()
		
		# rotate the player
		await get_tree().process_frame	
		player.rotation = GlobalMenu.get_current_level_rotation()
		player.global_position = start.global_position + Vector2(8, 0)
		
		add_child(player)
		GlobalPlayerStats.current_checkpoint = player.global_position
	else:
		print(" 'Sign_Start_Level' not found in", current_level.name)


func init_player() : 
	GlobalPlayerStats.player_current_HP = GlobalPlayerStats.player_max_HP
	GlobalPlayerStats.current_cheese_nb = 0
	GlobalPlayerStats.current_frostberry_number = 0
	# send signal to update HUD
	GlobalPlayerStats.update_berry_number.emit()
	GlobalPlayerStats.current_lives_number = 1
	# send signal to update HUD
	GlobalPlayerStats.update_life_number.emit()
