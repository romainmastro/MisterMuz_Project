extends Control

func _on_replay_pressed() -> void:
	GlobalMenu.set_game_state(GlobalMenu.GAME_STATES.PLAYING_GAME)

func _on_start_screen_pressed() -> void:
	GlobalMenu.set_game_state(GlobalMenu.GAME_STATES.MAIN_MENU)

func _on_quit_pressed() -> void:
	get_tree().quit()
