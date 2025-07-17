extends TreasureClass

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass :
		show_opened_chest()
		GlobalPlayerStats.has_muffler = true
		GlobalPlayerStats.has_muffler_signal.emit() # listened by animation component
