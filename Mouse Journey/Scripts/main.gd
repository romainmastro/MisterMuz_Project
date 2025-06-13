extends Node2D

enum GAME_STATES{START, GAME, CONGRATS, GAMEOVER}
var current_game_state = GAME_STATES.START

@export var player : PlayerClass
@export var HUD : CanvasLayer
@export var world: Node
@export var player_camera : Camera2D

var current_level : Node = null

func _ready() -> void: 
	
	load_current_level()
	starting_position(current_level)
	
	GlobalEnemyManager.spawn()

func load_current_level() : 
	var level_scene = GlobalLevelsManager.get_current_level()
	current_level = level_scene.instantiate()
	world.add_child(current_level)
	
	GlobalLevelsManager.level_completed.connect(on_level_completed)
	call_deferred("show_congrats")

func on_level_completed() : 
	if current_level : 
		current_level.call_deferred("queue_free")
		current_level = null
		
	call_deferred("show_congrats")

func show_congrats() : 
	var congrats_scene = preload("res://Scenes/UI/congrats_screen.tscn")
	var congrats = congrats_scene.instantiate()
	add_child(congrats)

func camera_on_player() : 
	player_camera.enabled = true

func starting_position(level) : 
	player.position = level.get_node("Sign_Start_Level").position
	GlobalPlayerStats.current_checkpoint = player.position

#TODO complete the function when levels are ready
#func handle_level_change() : 
		## handle the cameras
		#camera_on_player()
		#
		## determine next level and add the level to the tree
		#match GlobalPlayerStats.current_level : 
			#
			#GlobalPlayerStats.Levels.Level1 : 
				#GlobalPlayerStats.current_level = GlobalPlayerStats.Levels.Level2
				#
				#var level_to_load = Level2.instantiate()
				#
				#world.add_child(level_to_load, true)
				#
				#world.get_child(0).call_deferred("queue_free")
				#
				#starting_position(level_to_load)
				#
			#GlobalPlayerStats.Levels.Level2 :
				#GlobalPlayerStats.current_level = GlobalPlayerStats.Levels.Level3
#
			#GlobalPlayerStats.Levels.Level3 :
				#GlobalPlayerStats.current_level = GlobalPlayerStats.Levels.Level4
	#
			#_ : 
				#return
