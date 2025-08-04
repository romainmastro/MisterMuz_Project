extends Node

@export var nav_sound : AudioStreamPlayer
@export var conf_sound : AudioStreamPlayer

var last_hovered_button : Control = null

func _input(event: InputEvent) -> void:
	# Keyboard + GamePad
	if (event.is_action_pressed("ui_down") or 
		event.is_action_pressed("ui_up") or 
		event.is_action_pressed("ui_left") or 
		event.is_action_pressed("ui_right")):
		
		if not nav_sound.playing : 
			nav_sound.play()
	
	# Mouse
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered is Button:
			conf_sound.play()
			
	elif event.is_action_pressed("ui_accept") : 
		conf_sound.play()
	

func _process(_delta: float) -> void:
	# Mouse Nav
	var hovered = get_viewport().gui_get_hovered_control()
	
	if hovered != last_hovered_button : 
		last_hovered_button = hovered
		if hovered is Button : 
			nav_sound.play()
	
