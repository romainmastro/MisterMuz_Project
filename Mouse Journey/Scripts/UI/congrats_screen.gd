extends Control

@export var Congrats_camera : Camera2D

func _ready() -> void:
	hide()
	Congrats_camera.enabled = false

func _on_next_level_pressed() -> void:
	GlobalPlayerStats.next_level.emit() # listened by main.gd


func _on_replay_pressed() -> void:
	GlobalPlayerStats.replay.emit() # listened by main.gd
