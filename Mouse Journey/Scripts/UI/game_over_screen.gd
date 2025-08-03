extends Control

func _ready() -> void:
	$UI/VBoxContainer/Replay.grab_focus()

func _on_replay_pressed() -> void:
	GlobalMenu.game_transition(func():GlobalMenu.set_game_state(GlobalMenu.GAME_STATES.PLAYING_GAME))
	

func _on_start_screen_pressed() -> void:
	GlobalMenu.game_transition(func() : GlobalMenu.set_game_state(GlobalMenu.GAME_STATES.MAIN_MENU))
	

func _on_quit_pressed() -> void:
	GlobalMenu.game_transition(func() : get_tree().quit() )
	
