extends Control

func _ready() -> void:
	hide()

func _on_replay_pressed() -> void:
	GlobalPlayerStats.replay.emit() # listened by main.gd
