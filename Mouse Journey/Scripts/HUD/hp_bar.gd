extends HBoxContainer

var hp_full = preload("res://Assets/Collectibles/Collectible - Heart.png")
var hp_empty = preload("res://Assets/Collectibles/Collectible - Heart_empty.png")

func _ready() -> void:
	GlobalPlayerStats.max_hp_changed.connect(add_max_hp)

func update_health(value : float) :
        for i in range(get_child_count()):
                if value > i :
                        get_child(i).texture = hp_full
                else :
                        get_child(i).texture = hp_empty

func _process(_delta: float) -> void:
	
	update_health(GlobalPlayerStats.player_current_HP)

func add_max_hp() : 
	var hp = TextureRect.new()
	hp.texture = hp_full
	hp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	
	add_child(hp)
