extends Area2D

# if current_HP < max_HP : gains 1 HP
func _ready() -> void:
	scale = Vector2(1, 1)
	#$Sprite2D.scale = Vector2(0.5, 0.5)
	
func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		if GlobalPlayerStats.player_current_HP >= GlobalPlayerStats.player_max_HP : 
			print ("Muz is full life")
			return
		else : 
			GlobalPlayerStats.player_current_HP += 1
			call_deferred("queue_free")
