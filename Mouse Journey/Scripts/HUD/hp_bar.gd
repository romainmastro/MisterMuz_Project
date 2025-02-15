extends HBoxContainer

var hp_full = preload("res://Assets/UI/HP Bar/HealthBar_full.png")
var hp_empty = preload("res://Assets/UI/HP Bar/HealthBar_empty.png")


func update_health(value : float) : 
	for i in get_child_count() : 
		if value > i : 
			get_child(i).texture = hp_full
		else : 
			get_child(i).texture = hp_empty

func _process(_delta: float) -> void:
	
	update_health(GlobalPlayerStats.player_current_HP)
