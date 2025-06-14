extends Control

func _on_next_level_pressed() -> void:
	GlobalMenu.go_next_level()
	GlobalMenu.set_game_state(GlobalMenu.GAME_STATES.PLAYING_GAME)
	
func _on_replay_pressed() -> void:
	GlobalPlayerStats.replay.emit() # listened by main.gd
