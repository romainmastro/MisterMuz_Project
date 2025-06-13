extends Node2D

enum GAME_STATES{START, GAME, CONGRATS, GAMEOVER}
var current_game_state = GAME_STATES.START

@export var player : PlayerClass
@export var HUD : CanvasLayer

@onready var Level1_romain = preload("res://Scenes/Levels/level_1_romain.tscn")
@onready var Level1 = preload("res://Scenes/Levels/level_eline.tscn")
@onready var Level2 = preload("res://Scenes/Levels/level_sophie.tscn")
@onready var LevelTest = preload("res://Scenes/Levels/level_test.tscn")

@export var world: Node

@export var congrats_screen : Control
@export var congrats_camera : Camera2D

@export var game_over_screen : Control
@export var game_over_camera : Camera2D
@export var player_camera : Camera2D

func _ready() -> void: 
	
	GlobalPlayerStats.show_congrats_screen.connect(show_CongratsScreen)
	GlobalPlayerStats.show_game_over_screen.connect(show_GameOver)

	GlobalPlayerStats.next_level.connect(handle_level_change)
	
	var level_to_load = Level1_romain.instantiate()
	world.add_child(level_to_load, true)
	
	starting_position(level_to_load)
	
	GlobalEnemyManager.spawn()

func _process(delta: float) -> void:
	match current_game_state : 
		GAME_STATES.START : 
			pass
		GAME_STATES.GAME : 
			pass
		GAME_STATES.CONGRATS : 
			pass
		GAME_STATES.GAMEOVER : 
			pass

func show_CongratsScreen() : 
	HUD.hide()
	congrats_screen.show()
	camera_on_congrats()
	world.get_child(0).queue_free() 

func camera_on_congrats() : 
	player_camera.enabled = false
	congrats_camera.enabled = true

func show_GameOver() : 
	HUD.hide()
	game_over_screen.show()
	camera_on_gameOver()

func camera_on_gameOver() : 
	player_camera.enabled = false
	game_over_camera.enabled = true
	
func camera_on_player() : 
	player_camera.enabled = true
	congrats_camera.enabled = false
	game_over_camera.enabled = false

func starting_position(level) : 
	player.position = level.get_node("Sign_Start_Level").position
	GlobalPlayerStats.current_checkpoint = player.position

#TODO complete the function when levels are ready
func handle_level_change() : 
		# handle the cameras
		camera_on_player()
		
		# determine next level and add the level to the tree
		match GlobalPlayerStats.current_level : 
			
			GlobalPlayerStats.Levels.Level1 : 
				GlobalPlayerStats.current_level = GlobalPlayerStats.Levels.Level2
				
				var level_to_load = Level2.instantiate()
				
				world.add_child(level_to_load, true)
				
				world.get_child(0).call_deferred("queue_free")
				
				starting_position(level_to_load)
				
			GlobalPlayerStats.Levels.Level2 :
				GlobalPlayerStats.current_level = GlobalPlayerStats.Levels.Level3

			GlobalPlayerStats.Levels.Level3 :
				GlobalPlayerStats.current_level = GlobalPlayerStats.Levels.Level4
	
			_ : 
				return
