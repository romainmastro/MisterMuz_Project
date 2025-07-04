extends Control

var player : PlayerClass


func _on_continue_button_pressed() -> void:
	player = get_tree().current_scene.get_node("Main/PlayerV2")
	if not player : 
		printerr("ERROR : I can't find the player in the tree!")
	else : 
		GlobalMenu.game_transition(func() : 
			player.continue_game_use_a_life()
			# will show the player after the game restarts
			GlobalPlayerStats.update_life_number.emit()  # to label_lives in main.gd
			# ___________________________________________#
			get_tree().paused = false
			call_deferred("queue_free"))

func _on_quit_button_pressed() -> void:
	GlobalMenu.game_transition(func() : get_tree().quit() )


	
