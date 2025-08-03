extends Label
@onready var enemy_penguins: CharacterBody2D = $".."

func _process(delta: float) -> void:
	text = (str(enemy_penguins.current_state) + "// " + str(enemy_penguins.velocity.x) + "// " + str(enemy_penguins.direction)+ "// " 
	+ str(enemy_penguins.current_direction))
