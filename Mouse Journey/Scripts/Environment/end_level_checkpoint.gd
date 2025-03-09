extends Area2D

@export var fire_lit : AnimatedSprite2D

func _ready() -> void:
	fire_lit.hide()


#TODO : complete to go to Congrats Screen
func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		fire_lit.show()
		fire_lit.play("fire_lit")
		
		# The following code must go to the Congrats Screen Script
		#match GlobalPlayerStats.current_level : 
			#GlobalPlayerStats.Levels.Level1 : 
				#GlobalPlayerStats.current_level = GlobalPlayerStats.Levels.Level2
				#
			#GlobalPlayerStats.Levels.Level2 :
				#GlobalPlayerStats.current_level = GlobalPlayerStats.Levels.Level3
				#
			#GlobalPlayerStats.Levels.Level3 :
				#GlobalPlayerStats.current_level = GlobalPlayerStats.Levels.Level4
