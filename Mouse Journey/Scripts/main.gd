extends Node2D

@export var player : PlayerClass
@export var sign_start_level1 : Area2D
@export var sign_start_level2 : Area2D

@onready var congrats_screen: Control = $MENU/CongratsScreen

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") : 
		get_tree().quit()

func _ready() -> void: 
	
	GlobalPlayerStats.next_level.connect(update_level)
	GlobalPlayerStats.level_complete.connect(show_CongratsScreen)
	
	match GlobalPlayerStats.current_level : 
		
		GlobalPlayerStats.Levels.Level1 : 
			player.position = sign_start_level1.position
			GlobalPlayerStats.current_checkpoint = player.position
			
		GlobalPlayerStats.Levels.Level2 : 
			player.position = sign_start_level2.position
			GlobalPlayerStats.current_checkpoint = player.position

func update_level() : 
		match GlobalPlayerStats.current_level : 
			
			GlobalPlayerStats.Levels.Level1 : 
				GlobalPlayerStats.current_level = GlobalPlayerStats.Levels.Level2
				get_tree().change_scene_to_file("res://Scenes/Levels/level_sophie.tscn")
			GlobalPlayerStats.Levels.Level2 :
				GlobalPlayerStats.current_level = GlobalPlayerStats.Levels.Level3
				#get_tree().change_scene_to_file("res://Scenes/Levels/level_sophie.tscn")
			GlobalPlayerStats.Levels.Level3 :
				GlobalPlayerStats.current_level = GlobalPlayerStats.Levels.Level4
				#get_tree().change_scene_to_file("res://Scenes/Levels/level_sophie.tscn")
			_ : 
				return

func show_CongratsScreen() : 
	congrats_screen.show()
	print("yeah")
