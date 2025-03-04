extends Area2D

# COLLECT 3 to gain 1 Max HP

@export var hoveringObjectComponent : ClassHoveringObjectComponent

func _ready() -> void:
	scale = Vector2(1, 1)
	hoveringObjectComponent.float_up()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		GlobalPlayerStats.current_cheese_nb += 1
		
		call_deferred("queue_free")
		
		if GlobalPlayerStats.current_cheese_nb == 3 : 
			GlobalPlayerStats.player_max_HP += 1
			# emit global signal to HP BAR  (see main)
			GlobalPlayerStats.max_hp_changed.emit()
			# reset the number of cheese to 0
			GlobalPlayerStats.current_cheese_nb = 0
			
		print("Number of Cheese : ", GlobalPlayerStats.current_cheese_nb)
		print("Player max life : ", GlobalPlayerStats.player_max_HP)


	
