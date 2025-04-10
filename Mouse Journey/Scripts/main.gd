extends Node2D

@export var player : PlayerClass

@onready var Level1 = preload("res://Scenes/Levels/level_eline.tscn")
@onready var Level2 = preload("res://Scenes/Levels/level_sophie.tscn")
@onready var LevelTest = preload("res://Scenes/Levels/level_test.tscn")

@export var world: Node

@export var congrats_screen : Control
@export var player_camera : Camera2D
@export var congrats_camera : Camera2D

func show_CongratsScreen() : 
	congrats_screen.show()
	camera_on_congrats()

func camera_on_congrats() : 
	player_camera.enabled = false
	congrats_camera.enabled = true

func camera_on_player() : 
	player_camera.enabled = true
	congrats_camera.enabled = false

func starting_position(level) : 
	player.position = level.get_node("Sign_Start_Level").position
	GlobalPlayerStats.current_checkpoint = player.position

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

func _ready() -> void: 
	
	GlobalPlayerStats.show_congrats_screen.connect(show_CongratsScreen)
	GlobalPlayerStats.next_level.connect(handle_level_change)
	
	var level_to_load = Level1.instantiate()
	world.add_child(level_to_load, true)
	
	starting_position(level_to_load)
