extends HBoxContainer

var hp_full = preload("res://Assets/Collectibles/Collectible - Cheese.png")
var hp_empty = preload("res://Assets/Collectibles/Collectible - Cheese_empty.png")


func update_cheese(value : float) : 
	for i in get_child_count() : 
		if value > i : 
			get_child(i).texture = hp_full
		else : 
			get_child(i).texture = hp_empty

func _process(_delta: float) -> void:
	
	update_cheese(GlobalPlayerStats.current_cheese_nb)
