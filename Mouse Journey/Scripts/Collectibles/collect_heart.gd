extends Area2D

@export var hoveringObjectComponent : ClassHoveringObjectComponent
var random_start : float
# if current_HP < max_HP : gains 1 HP
func _ready() -> void:
	scale = Vector2(1, 1)
	random_start = randf_range(0.0, 0.7)
	await get_tree().create_timer(random_start).timeout
	hoveringObjectComponent.float_up()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		if GlobalPlayerStats.player_current_HP >= GlobalPlayerStats.player_max_HP : 
			print ("Muz is full life")
			return
		else : 
			GlobalPlayerStats.player_current_HP += 1
			call_deferred("queue_free")


	
