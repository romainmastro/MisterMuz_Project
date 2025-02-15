extends Area2D


func _on_body_entered(_body: Node2D) -> void:
	GlobalPlayerStats.current_checkpoint = global_position
