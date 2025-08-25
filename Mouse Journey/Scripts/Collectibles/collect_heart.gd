extends Area2D

# if full life : gaining 1 heart converts to 3 frostberries

@export var hoveringObjectComponent : ClassHoveringObjectComponent
var random_start : float
var deactivation_time : float = 0.8
# if current_HP < max_HP : gains 1 HP
func _ready() -> void:
	deactivate_monitoring()
	scale = Vector2(1, 1)
	random_start = randf_range(0.0, 0.7)
	await get_tree().create_timer(random_start).timeout
	hoveringObjectComponent.float_up()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass : 
		if GlobalPlayerStats.player_current_HP >= GlobalPlayerStats.player_max_HP : 
			
			GlobalPlayerStats.current_frostberry_number += 3
			GlobalPlayerStats.update_berry_number.emit() # for label_berry in main.gd
			
			
			
			if GlobalPlayerStats.current_frostberry_number >= GlobalPlayerStats.max_frostberry_number : 
				GlobalPlayerStats.current_lives_number += 1
				GlobalPlayerStats.gain_one_life_fx.emit() # for player.gd
				GlobalPlayerStats.update_life_number.emit() # for label_lifes in main.gd
				GlobalPlayerStats.current_frostberry_number = 0
				GlobalPlayerStats.update_berry_number.emit() # for label_berry in main.gd

		else : 
			GlobalPlayerStats.player_current_HP += 1
		
		GlobalPlayerStats.heart_picked_up.emit() # for player_v3.gd for sounds
		call_deferred("queue_free")

func deactivate_monitoring() : 
	monitorable = false
	monitoring = false
	await get_tree().create_timer(deactivation_time).timeout
	monitorable = true
	monitoring = true
	
