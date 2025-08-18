extends Area2D

# COLLECT 100 to gain 1 life

@export var hoveringObjectComponent : ClassHoveringObjectComponent
var random_off_start : float
@export var deactivation_time : float = 0.8
@export var pickupFX : AudioStreamPlayer

func _ready() -> void:
	deactivate_monitoring()
	random_off_start = randf_range(0.0, 0.7)
	await get_tree().create_timer(random_off_start).timeout
	hoveringObjectComponent.float_up()

	
	
func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		GlobalPlayerStats.current_frostberry_number += 1
		GlobalPlayerStats.update_berry_number.emit() # for label_berry in main.gd
		GlobalPlayerStats.frostberry_picked_up.emit() # for player_V3.gd to play sound
		
		call_deferred("queue_free")
		
		
		if GlobalPlayerStats.current_frostberry_number >= GlobalPlayerStats.max_frostberry_number : 
			GlobalPlayerStats.current_lives_number += 1
			GlobalPlayerStats.update_life_number.emit() # for label_lifes in main.gd
			GlobalPlayerStats.current_frostberry_number = 0
			GlobalPlayerStats.update_berry_number.emit() # for label_berry in main.gd

func deactivate_monitoring() : 
	monitorable = false
	monitoring = false
	await get_tree().create_timer(deactivation_time).timeout
	monitorable = true
	monitoring = true
