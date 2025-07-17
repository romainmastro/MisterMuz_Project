extends Area2D

# COLLECT 3 to gain 1 Max HP

@export var hoveringObjectComponent : ClassHoveringObjectComponent
var random_start : float
var deactivation_time : float = 0.8

func _ready() -> void:
	deactivate_monitoring()
	scale = Vector2(1, 1)
	random_start = randf_range(0.0, 0.7)
	await get_tree().create_timer(random_start).timeout
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

func deactivate_monitoring() : 
	monitorable = false
	monitoring = false
	await get_tree().create_timer(deactivation_time).timeout
	monitorable = true
	monitoring = true

	
