extends Node

func _ready() -> void:
	init_game()

func init_game() : 
	GlobalMenu.set_game_state(GlobalMenu.GAME_STATES.MAIN_MENU)
	
