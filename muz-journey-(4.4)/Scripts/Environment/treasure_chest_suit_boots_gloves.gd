extends TreasureClass

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass :
		show_opened_chest()
		GlobalPlayerStats.has_boots_gloves_suit = true
		GlobalPlayerStats.has_boots_gloves_suit_signal.emit() 
		# listened by movement_with_slide_component.gd to update the movement accel/deccel variables
		# listened by animation component
