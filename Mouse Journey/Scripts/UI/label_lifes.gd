extends Label

func _ready() -> void:
	text = "X " + str(GlobalPlayerStats.current_lives_number)
	GlobalPlayerStats.update_life_number.connect(update_lives_number)

func update_lives_number() : 
	text = "X " + str(GlobalPlayerStats.current_lives_number)
