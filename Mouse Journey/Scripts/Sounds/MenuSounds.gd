extends Node

@export var nav_sound : AudioStreamPlayer
@export var conf_sound : AudioStreamPlayer

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") : 
		if not nav_sound.playing : 
			nav_sound.play()
	elif event.is_action_pressed("ui_accept") : 
		conf_sound.play()
