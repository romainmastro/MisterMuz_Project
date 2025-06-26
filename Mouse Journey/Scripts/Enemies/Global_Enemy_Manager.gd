extends Node

# List of enemy scenes
const SNOWMAN = preload("res://Scenes/Enemies/snowman.tscn")
const ENEMY_SNOW_CANNON = preload("res://Scenes/Enemies/enemy_snow_cannon.tscn")
const SNOW_MOLE_V_2 = preload("res://Scenes/Enemies/snow_mole_v_2.tscn")
const SUPER_SNOWMAN = preload("res://Scenes/Enemies/super_snowman.tscn")
const PENGUINS = preload("res://Scenes/Enemies/enemy_penguins.tscn")

var enemy_node_path : Node2D

func spawn() : 
	enemy_node_path = get_tree().get_root().get_node("Game/Main/WORLD").get_child(0)
	if not enemy_node_path:
		push_error("Enemy node path not found. Check scene structure!")
	
	if get_tree().get_node_count_in_group("enemies") > 0 : 
		for child in get_tree().get_nodes_in_group("enemies") : 
			child.queue_free()
		await get_tree().process_frame
		
	for node in get_tree().get_nodes_in_group("enemy_spawn_points") : 
	
		match node.enemy_type : 
			"SnowMan" : 
				var snowman = SNOWMAN.instantiate()
				snowman.global_position = node.global_position
				snowman.speed = node.speed
				snowman.direction_départ = node.direction_départ
				enemy_node_path.add_child(snowman, true)
			"SnowCanon" : 
				var snowcanon = ENEMY_SNOW_CANNON.instantiate()
				snowcanon.global_position = node.global_position
				snowcanon.speed = node.speed
				snowcanon.direction_départ = node.direction_départ
				enemy_node_path.add_child(snowcanon, true)
			"SnowMole" : 
				var snowmole = SNOW_MOLE_V_2.instantiate()
				snowmole.global_position = node.global_position
				snowmole.hop_force = node.hop_force
				snowmole.attacking_force = node.attacking_force
				snowmole.switch_mound_wait_time = node.switch_mound_wait_time
				snowmole.underground_timer_wait_time = node.underground_timer_wait_time
				enemy_node_path.add_child(snowmole, true)
			"SuperSnowMan":
				var super_snowman = SUPER_SNOWMAN.instantiate()
				super_snowman.global_position = node.global_position
				super_snowman.speed = node.speed
				super_snowman.direction_départ = node.direction_départ
				enemy_node_path.add_child(super_snowman, true)
			"Penguins" : 
				var penguin = PENGUINS.instantiate()
				penguin.global_position = node.global_position
				penguin.speed = node.speed
				penguin.direction_départ = node.direction_départ
				enemy_node_path.add_child(penguin, true)
			_ : 
				printerr("The enemy doesn't exist! See GlobalEnemyManager")
