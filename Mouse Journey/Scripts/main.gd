extends Node2D

@export var player : PlayerClass
@export var sign_start_level1 : Area2D
@export var sign_start_level2 : Area2D

@export var Level1 : Node2D
@export var Level2 : Node2D
@export var Level3 : Node2D
@export var Level4 : Node2D

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

func starting_position() : 
	
	match GlobalPlayerStats.current_level : 
		
		GlobalPlayerStats.Levels.Level1 : 
			player.position = sign_start_level1.position
			GlobalPlayerStats.current_checkpoint = player.position
			
		GlobalPlayerStats.Levels.Level2 : 
			player.position = sign_start_level2.position
			GlobalPlayerStats.current_checkpoint = player.position

func disable_level(level : Node2D) : 
	# get through the children of the Level Node2D and disable/enable the tilelayers
	for i in level.get_children() : 
		if i is TileMapLayer : 
			i.enabled = false

func enable_level(level : Node2D) : 
	# get through the children of the Level Node2D and disable/enable the tilelayers
	for i in level.get_children() : 
		if i is TileMapLayer : 
			i.enabled = true

func update_current_level() : 
		# handle the cameras
		camera_on_player()
		
		# determine next level and add the level to the tree
		match GlobalPlayerStats.current_level : 
			
			GlobalPlayerStats.Levels.Level1 : 
				GlobalPlayerStats.current_level = GlobalPlayerStats.Levels.Level2
				enable_level(Level2)
				disable_level(Level1)
				starting_position()
				
			GlobalPlayerStats.Levels.Level2 :
				GlobalPlayerStats.current_level = GlobalPlayerStats.Levels.Level3
				enable_level(Level3)
				disable_level(Level2)
				starting_position()
				
			GlobalPlayerStats.Levels.Level3 :
				GlobalPlayerStats.current_level = GlobalPlayerStats.Levels.Level4
				enable_level(Level4)
				disable_level(Level3)
				starting_position()
			_ : 
				return

func _ready() -> void: 
	
	GlobalPlayerStats.show_congrats_screen.connect(show_CongratsScreen)
	GlobalPlayerStats.next_level.connect(update_current_level)
	
	enable_level(Level1)
	disable_level(Level2)
	
	starting_position()
