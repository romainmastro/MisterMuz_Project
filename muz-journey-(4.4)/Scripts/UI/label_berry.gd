extends Label

func _ready() : 
	text = "X " + str(GlobalPlayerStats.current_frostberry_number)
	GlobalPlayerStats.update_berry_number.connect(handle_update_berry_number)
	
func handle_update_berry_number() : 
	text = "X " + str(GlobalPlayerStats.current_frostberry_number)
