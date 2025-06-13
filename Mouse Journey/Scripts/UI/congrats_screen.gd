extends Control

func _on_next_level_pressed() -> void:
	GlobalPlayerStats.next_level.emit() #listened by main.gd
func _on_replay_pressed() -> void:
	GlobalPlayerStats.replay.emit() # listened by main.gd
