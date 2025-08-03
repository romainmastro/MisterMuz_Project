extends TreasureClass

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass :
		show_opened_chest()
		GlobalPlayerStats.has_snow_hat = true
		GlobalPlayerStats.has_snowHat_signal.emit() 
		# listened by animation component
